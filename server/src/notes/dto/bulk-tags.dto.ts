import { ArrayMaxSize, IsArray, IsNotEmpty, IsString } from 'class-validator';
import {
  BULK_MAX_NOTE_IDS,
  BULK_MAX_TAG_IDS,
} from '../constants/notes.constants';

export class BulkTagsDto {
  @IsArray()
  @ArrayMaxSize(BULK_MAX_NOTE_IDS)
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  noteIds: string[];

  @IsArray()
  @ArrayMaxSize(BULK_MAX_TAG_IDS)
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  tagIds: string[];
}
