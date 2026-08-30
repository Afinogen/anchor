import { ConflictException, NotFoundException } from '@nestjs/common';
import { TagsService } from './tags.service';
import { PrismaService } from '../prisma/prisma.service';
import { createMockSyncEmitter, asSyncEmitter } from '../../test/sync-mocks';

/**
 * TagsService against an in-memory tag store: name-uniqueness rules for CRUD.
 */
describe('TagsService', () => {
  const USER = 'user-1';
  const OTHER = 'user-2';

  interface TagRecord {
    id: string;
    name: string;
    color: string | null;
    userId: string;
    isDeleted: boolean;
    updatedAt: Date;
  }

  let tags: Map<string, TagRecord>;
  let service: TagsService;

  const baseAt = new Date('2026-07-01T12:00:00.000Z');

  const makeTag = (overrides: Partial<TagRecord> & { id: string }) => {
    const tag: TagRecord = {
      name: `name-${overrides.id}`,
      color: null,
      userId: USER,
      isDeleted: false,
      updatedAt: baseAt,
      ...overrides,
    };
    tags.set(tag.id, tag);
    return tag;
  };

  const nameTaken = (name: string, userId: string, exceptId?: string) =>
    [...tags.values()].some(
      (t) =>
        t.name === name &&
        t.userId === userId &&
        !t.isDeleted &&
        t.id !== exceptId,
    );

  const withCount = (tag: TagRecord) => ({ ...tag, _count: { notes: 0 } });

  interface TagFindFirstWhere {
    userId: string;
    name: string;
    isDeleted: boolean;
    id?: { not: string };
  }

  const tagFindFirst = jest.fn(({ where }: { where: TagFindFirstWhere }) =>
    Promise.resolve(
      [...tags.values()].find(
        (t) =>
          t.userId === where.userId &&
          t.name === where.name &&
          t.isDeleted === where.isDeleted &&
          (where.id === undefined || t.id !== where.id.not),
      ) ?? null,
    ),
  );

  const tagFindUnique = jest.fn(({ where }: { where: { id: string } }) => {
    const tag = tags.get(where.id);
    return Promise.resolve(tag ? withCount(tag) : null);
  });

  const tagFindUniqueOrThrow = jest.fn(
    ({ where }: { where: { id: string } }) => {
      const tag = tags.get(where.id);
      return tag
        ? Promise.resolve(withCount(tag))
        : Promise.reject(new Error('Tag not found'));
    },
  );

  const tagCreate = jest.fn(
    ({
      data,
    }: {
      data: {
        id?: string;
        name: string;
        color?: string | null;
        userId: string;
      };
    }) => {
      // The DB enforces (userId, name) uniqueness for live tags.
      if (nameTaken(data.name, data.userId)) {
        return Promise.reject(new Error('Unique constraint failed'));
      }
      const tag = makeTag({
        id: data.id ?? `tag-${tags.size + 1}`,
        name: data.name,
        color: data.color ?? null,
        userId: data.userId,
        updatedAt: new Date(),
      });
      return Promise.resolve(withCount(tag));
    },
  );

  const tagUpdate = jest.fn(
    ({ where, data }: { where: { id: string }; data: Partial<TagRecord> }) => {
      const tag = tags.get(where.id)!;
      Object.assign(tag, data, { updatedAt: new Date() });
      return Promise.resolve(withCount(tag));
    },
  );

  // Optimistic guard: only writes when updatedAt still matches.
  const tagUpdateMany = jest.fn(
    ({
      where,
      data,
    }: {
      where: { id: string; userId: string; updatedAt: Date };
      data: Partial<TagRecord>;
    }) => {
      const tag = tags.get(where.id);
      if (
        !tag ||
        tag.userId !== where.userId ||
        tag.updatedAt.getTime() !== where.updatedAt.getTime()
      ) {
        return Promise.resolve({ count: 0 });
      }
      if (data.name !== undefined && nameTaken(data.name, tag.userId, tag.id)) {
        return Promise.reject(new Error('Unique constraint failed'));
      }
      Object.assign(tag, data, { updatedAt: new Date() });
      return Promise.resolve({ count: 1 });
    },
  );

  interface DateWindow {
    gt?: Date;
    lte?: Date;
  }

  const inWindow = (date: Date, window: DateWindow) =>
    (window.gt === undefined || date > window.gt) &&
    (window.lte === undefined || date <= window.lte);

  const tagFindMany = jest.fn(
    ({
      where,
    }: {
      where: {
        userId: string;
        updatedAt?: DateWindow;
        OR?: Array<{ updatedAt?: DateWindow; id?: { in: string[] } }>;
      };
    }) => {
      const matches = (t: TagRecord) => {
        if (where.updatedAt) return inWindow(t.updatedAt, where.updatedAt);
        return (where.OR ?? []).some((clause) =>
          clause.updatedAt
            ? inWindow(t.updatedAt, clause.updatedAt)
            : (clause.id?.in ?? []).includes(t.id),
        );
      };
      return Promise.resolve(
        [...tags.values()]
          .filter((t) => t.userId === where.userId && matches(t))
          .map(withCount),
      );
    },
  );

  const prisma = {
    $transaction: (cb: (tx: PrismaService) => unknown) => cb(prisma),
    tag: {
      findFirst: tagFindFirst,
      findUnique: tagFindUnique,
      findUniqueOrThrow: tagFindUniqueOrThrow,
      findMany: tagFindMany,
      create: tagCreate,
      update: tagUpdate,
      updateMany: tagUpdateMany,
    },
  } as unknown as PrismaService;

  beforeEach(() => {
    tags = new Map();
    service = new TagsService(prisma, asSyncEmitter(createMockSyncEmitter()));
    jest.clearAllMocks();
  });

  describe('create / update / remove', () => {
    it('rejects a duplicate live tag name', async () => {
      makeTag({ id: 'tag-1', name: 'Work' });
      await expect(service.create(USER, { name: 'Work' })).rejects.toThrow(
        ConflictException,
      );
    });

    it('allows reusing the name of a deleted tag', async () => {
      makeTag({ id: 'tag-1', name: 'Work', isDeleted: true });
      const created = await service.create(USER, { name: 'Work' });
      expect(created.name).toBe('Work');
    });

    it('rejects renaming a tag onto an existing name', async () => {
      makeTag({ id: 'tag-1', name: 'Work' });
      makeTag({ id: 'tag-2', name: 'Home' });
      await expect(
        service.update(USER, 'tag-2', { name: 'Work' }),
      ).rejects.toThrow(ConflictException);
    });

    it('allows saving a tag under its own name', async () => {
      makeTag({ id: 'tag-1', name: 'Work' });
      const updated = await service.update(USER, 'tag-1', {
        name: 'Work',
        color: '#f00',
      });
      expect(updated.color).toBe('#f00');
    });

    it("hides other users' tags", async () => {
      makeTag({ id: 'tag-1', userId: OTHER });
      await expect(service.findOne(USER, 'tag-1')).rejects.toThrow(
        NotFoundException,
      );
      await expect(service.remove(USER, 'tag-1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('remove soft-deletes so sync clients learn about it', async () => {
      makeTag({ id: 'tag-1' });
      await service.remove(USER, 'tag-1');
      expect(tags.get('tag-1')!.isDeleted).toBe(true);
      expect(tags.has('tag-1')).toBe(true);
    });
  });
});
