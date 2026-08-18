import {
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';
import { MAX_REVISION_PAGE_SIZE } from '../constants/notes.constants';

export class ListNoteRevisionsDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_REVISION_PAGE_SIZE)
  @IsOptional()
  limit?: number;

  // The id of the last revision the client already has.
  @IsString()
  @IsOptional()
  cursor?: string;

  @Transform(({ value }) => value === true || value === 'true')
  @IsBoolean()
  @IsOptional()
  withContent?: boolean;
}
