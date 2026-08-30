import { IsOptional, MinLength } from 'class-validator';
import { RejectUnknownFields } from '../../common/decorators/reject-unknown-fields.decorator';

@RejectUnknownFields()
export class ResetPasswordDto {
  @IsOptional()
  @MinLength(8)
  newPassword?: string;
}
