import { PartialType } from '@nestjs/mapped-types';
import { IsInt, IsOptional, Min } from 'class-validator';
import { CreateTagDto } from './create-tag.dto';

export class UpdateTagDto extends PartialType(CreateTagDto) {
  // Stale → 409 with the full serverTag; absent → unconditional write.
  @IsInt()
  @Min(1)
  @IsOptional()
  baseVersion?: number;
}
