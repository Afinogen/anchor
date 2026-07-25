import { BadRequestException } from '@nestjs/common';
import { AttachmentType } from 'src/generated/prisma/enums';
import { ATTACHMENT_MAX_FILE_SIZE } from '../constants/notes.constants';
import {
  assertValidAttachmentFile,
  attachmentTypeForMime,
} from './attachment-storage.util';

const fileOf = (overrides: Partial<Express.Multer.File>): Express.Multer.File =>
  ({ mimetype: 'image/png', size: 1024, ...overrides }) as Express.Multer.File;

describe('assertValidAttachmentFile', () => {
  it('accepts an allowed type within the size limit', () => {
    expect(() => assertValidAttachmentFile(fileOf({}))).not.toThrow();
  });

  it('rejects a missing file', () => {
    expect(() => assertValidAttachmentFile(undefined)).toThrow(
      BadRequestException,
    );
  });

  it('rejects a disallowed MIME type', () => {
    expect(() =>
      assertValidAttachmentFile(fileOf({ mimetype: 'application/pdf' })),
    ).toThrow(/not allowed/);
  });

  it('rejects a file over the size limit', () => {
    expect(() =>
      assertValidAttachmentFile(fileOf({ size: ATTACHMENT_MAX_FILE_SIZE + 1 })),
    ).toThrow(/exceeds/);
  });
});

describe('attachmentTypeForMime', () => {
  it('maps image types to image', () => {
    expect(attachmentTypeForMime('image/jpeg')).toBe(AttachmentType.image);
  });

  it('maps non-image types to audio', () => {
    expect(attachmentTypeForMime('audio/mpeg')).toBe(AttachmentType.audio);
  });
});
