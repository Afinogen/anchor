import { PartialType } from '@nestjs/mapped-types';
import { IsInt, IsOptional, Min } from 'class-validator';
import { CreateNoteDto } from './create-note.dto';

export class UpdateNoteDto extends PartialType(CreateNoteDto) {
  // Version the client based its edit on. Stale → 409 with the full
  // serverNote; absent → unconditional write.
  @IsInt()
  @Min(1)
  @IsOptional()
  baseVersion?: number;
}
