import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsNotEmpty,
  IsString,
} from 'class-validator';
import { BULK_MAX_NOTE_IDS } from '../constants/notes.constants';

export class BulkPinDto {
  @IsArray()
  @ArrayMaxSize(BULK_MAX_NOTE_IDS)
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  noteIds: string[];

  @IsBoolean()
  isPinned: boolean;
}
