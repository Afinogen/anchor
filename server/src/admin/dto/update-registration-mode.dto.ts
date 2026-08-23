import { IsIn } from 'class-validator';
import { RejectUnknownFields } from '../../common/decorators/reject-unknown-fields.decorator';

@RejectUnknownFields()
export class UpdateRegistrationModeDto {
  @IsIn(['disabled', 'enabled', 'review'])
  mode: 'disabled' | 'enabled' | 'review';
}
