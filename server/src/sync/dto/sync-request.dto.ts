import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsEnum,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import {
  MAX_SYNC_CHANGES,
  MAX_SYNC_LIMIT,
  MIN_SYNC_LIMIT,
} from '../sync.constants';

export enum SyncNoteState {
  active = 'active',
  trashed = 'trashed',
  deleted = 'deleted',
}

// For pins `id` is the noteId; there is no pin entity of its own.
export class SyncChangeBaseDto {
  @IsIn(['note', 'tag', 'pin'])
  type: 'note' | 'tag' | 'pin';

  @IsString()
  id: string;
}

// Pushes carry the client's whole coalesced row; pins travel as their own
// change type.
export class SyncNoteChangeDto extends SyncChangeBaseDto {
  declare type: 'note';

  // Absent on an existing note means the client never reconciled a server
  // version, so it loses: conflict, nothing clobbered.
  @IsInt()
  @Min(1)
  @IsOptional()
  baseVersion?: number;

  @IsString()
  title: string;

  @IsString()
  @IsOptional()
  content?: string;

  @IsBoolean()
  @IsOptional()
  isArchived?: boolean;

  @IsString()
  @IsOptional()
  background?: string;

  @IsEnum(SyncNoteState)
  @IsOptional()
  state?: SyncNoteState;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  tagIds?: string[];
}

export class SyncTagChangeDto extends SyncChangeBaseDto {
  declare type: 'tag';

  @IsInt()
  @Min(1)
  @IsOptional()
  baseVersion?: number;

  @IsString()
  name: string;

  @IsString()
  @IsOptional()
  color?: string;

  @IsBoolean()
  @IsOptional()
  isDeleted?: boolean;
}

export class SyncPinChangeDto extends SyncChangeBaseDto {
  declare type: 'pin';

  @IsBoolean()
  isPinned: boolean;
}

export type SyncChange =
  | SyncNoteChangeDto
  | SyncTagChangeDto
  | SyncPinChangeDto;

export class SyncRequestDto {
  @IsString()
  @IsOptional()
  cursor?: string;

  @IsInt()
  @Min(MIN_SYNC_LIMIT)
  @Max(MAX_SYNC_LIMIT)
  @IsOptional()
  limit?: number;

  @IsArray()
  @ArrayMaxSize(MAX_SYNC_CHANGES)
  @ValidateNested({ each: true })
  @Type(() => SyncChangeBaseDto, {
    discriminator: {
      property: 'type',
      subTypes: [
        { value: SyncNoteChangeDto, name: 'note' },
        { value: SyncTagChangeDto, name: 'tag' },
        { value: SyncPinChangeDto, name: 'pin' },
      ],
    },
    keepDiscriminatorProperty: true,
  })
  @IsOptional()
  changes?: SyncChange[];
}
