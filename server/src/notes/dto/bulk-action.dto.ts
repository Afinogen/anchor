import { ArrayMaxSize, IsArray, IsString, IsNotEmpty } from 'class-validator';
import { BULK_MAX_NOTE_IDS } from '../constants/notes.constants';

export class BulkActionDto {
  @IsArray()
  @ArrayMaxSize(BULK_MAX_NOTE_IDS)
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  noteIds: string[];
}
