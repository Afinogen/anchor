import { Logger } from '@nestjs/common';
import * as fs from 'fs/promises';

/**
 * Delete a file, treating "already gone" as success. Any other failure is
 * logged (when a logger is given) rather than thrown, so cleanup paths never
 * mask the original error.
 */
export async function deleteFileIfExists(
  filePath: string,
  logger?: Logger,
): Promise<void> {
  try {
    await fs.unlink(filePath);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code !== 'ENOENT') {
      logger?.error(`Failed to delete file: ${filePath}`);
    }
  }
}
