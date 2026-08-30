import { BadRequestException } from '@nestjs/common';
import * as crypto from 'crypto';
import * as fs from 'fs/promises';
import * as path from 'path';
import { AttachmentType } from 'src/generated/prisma/enums';
import {
  ATTACHMENT_ALLOWED_MIME_TYPES,
  ATTACHMENT_MAX_FILE_SIZE,
} from '../constants/notes.constants';
import { t } from '../../i18n/i18n.util';

export function assertValidAttachmentFile(file?: Express.Multer.File): void {
  if (!file) {
    throw new BadRequestException(t('notes.noFileProvided'));
  }
  if (!ATTACHMENT_ALLOWED_MIME_TYPES.has(file.mimetype)) {
    throw new BadRequestException(
      t('notes.fileTypeNotAllowed', { type: file.mimetype }),
    );
  }
  if (file.size > ATTACHMENT_MAX_FILE_SIZE) {
    throw new BadRequestException(
      t('notes.fileTooLarge', {
        size: ATTACHMENT_MAX_FILE_SIZE / 1024 / 1024,
      }),
    );
  }
}

export function attachmentTypeForMime(mimeType: string): AttachmentType {
  return mimeType.startsWith('image/')
    ? AttachmentType.image
    : AttachmentType.audio;
}

export async function writeAttachmentFile(
  noteDir: string,
  originalName: string,
  data: Buffer,
): Promise<{ storedFilename: string; filePath: string }> {
  await fs.mkdir(noteDir, { recursive: true });

  const ext = path.extname(originalName).toLowerCase();
  const storedFilename = `${crypto.randomUUID()}-${Date.now()}${ext}`;
  const filePath = path.join(noteDir, storedFilename);

  await fs.writeFile(filePath, data);
  return { storedFilename, filePath };
}
