import {
  Injectable,
  PipeTransform,
  ValidationPipe,
  type ArgumentMetadata,
} from '@nestjs/common';
import { rejectsUnknownFields } from '../decorators/reject-unknown-fields.decorator';

/** Strips unknown fields, except on DTOs marked `@RejectUnknownFields`. */
@Injectable()
export class AppValidationPipe implements PipeTransform {
  private readonly tolerant = new ValidationPipe({
    whitelist: true,
    transform: true,
  });

  private readonly strict = new ValidationPipe({
    whitelist: true,
    transform: true,
    forbidNonWhitelisted: true,
  });

  transform(value: unknown, metadata: ArgumentMetadata): Promise<unknown> {
    const pipe = rejectsUnknownFields(metadata.metatype)
      ? this.strict
      : this.tolerant;
    return pipe.transform(value, metadata);
  }
}
