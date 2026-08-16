import type { Prisma } from 'src/generated/prisma/client';

// Only tags the caller owns (and hasn't deleted) may be attached; unknown
// or foreign ids are dropped instead of failing the whole request.
export async function ownedTagIds(
  db: Prisma.TransactionClient,
  userId: string,
  tagIds?: string[],
): Promise<string[]> {
  if (!tagIds?.length) {
    return [];
  }
  const tags = await db.tag.findMany({
    where: { id: { in: tagIds }, userId, isDeleted: false },
    select: { id: true },
  });
  return tags.map((tag) => tag.id);
}

// Sync the caller's own tags on a note to `desiredTagIds`, leaving other
// users' tags untouched.
export async function reconcileUserTags(
  tx: Prisma.TransactionClient,
  noteId: string,
  userId: string,
  desiredTagIds: string[],
): Promise<void> {
  const desired = new Set(await ownedTagIds(tx, userId, desiredTagIds));

  const attached = await tx.tag.findMany({
    where: { userId, notes: { some: { id: noteId } } },
    select: { id: true },
  });
  const current = new Set(attached.map((t) => t.id));

  const toConnect = [...desired].filter((id) => !current.has(id));
  const toDisconnect = [...current].filter((id) => !desired.has(id));

  if (toConnect.length === 0 && toDisconnect.length === 0) {
    return;
  }

  await tx.note.update({
    where: { id: noteId },
    data: {
      tags: {
        connect: toConnect.map((id) => ({ id })),
        disconnect: toDisconnect.map((id) => ({ id })),
      },
    },
  });
}
