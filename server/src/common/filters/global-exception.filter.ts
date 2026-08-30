import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { HttpAdapterHost } from '@nestjs/core';

/**
 * Catches every unhandled exception and returns one consistent JSON shape.
 * HttpException responses (including ValidationPipe output) pass through with
 * their status and message intact; anything else becomes a 500 with a generic
 * message so internal errors never leak, and is logged with its stack.
 */
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  constructor(private readonly httpAdapterHost: HttpAdapterHost) {}

  catch(exception: unknown, host: ArgumentsHost): void {
    const { httpAdapter } = this.httpAdapterHost;
    const ctx = host.switchToHttp();
    const request = ctx.getRequest<unknown>();
    const path = httpAdapter.getRequestUrl(request) as string;
    const timestamp = new Date().toISOString();

    const declared =
      exception instanceof HttpException ? exception.getStatus() : undefined;
    const status = isHttpStatus(declared)
      ? declared
      : HttpStatus.INTERNAL_SERVER_ERROR;

    let body: Record<string, unknown>;
    if (exception instanceof HttpException) {
      const response = exception.getResponse();
      const base =
        typeof response === 'string'
          ? { statusCode: status, message: response }
          : (response as Record<string, unknown>);
      body = { ...base, statusCode: status, timestamp, path };
    } else {
      body = {
        statusCode: status,
        error: 'Internal Server Error',
        message: 'Internal server error',
        timestamp,
        path,
      };
    }

    if (status >= 500) {
      const method = httpAdapter.getRequestMethod(request) as string;
      this.logger.error(
        `${method} ${path} -> ${status}`,
        exception instanceof Error ? exception.stack : String(exception),
      );
    }

    httpAdapter.reply(ctx.getResponse(), body, status);
  }
}

const isHttpStatus = (status: unknown): status is number =>
  Number.isInteger(status) &&
  (status as number) >= 100 &&
  (status as number) < 600;
