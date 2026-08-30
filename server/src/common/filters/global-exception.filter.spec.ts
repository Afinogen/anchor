import 'reflect-metadata';
import {
  ArgumentsHost,
  BadRequestException,
  HttpException,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { HttpAdapterHost } from '@nestjs/core';
import { GlobalExceptionFilter } from './global-exception.filter';

describe('GlobalExceptionFilter', () => {
  let filter: GlobalExceptionFilter;
  let reply: jest.Mock;
  let response: object;
  let errorLog: jest.SpyInstance;

  const host = {
    switchToHttp: () => ({
      getRequest: () => ({}),
      getResponse: () => response,
    }),
  } as unknown as ArgumentsHost;

  beforeEach(() => {
    reply = jest.fn();
    response = {};
    errorLog = jest
      .spyOn(Logger.prototype, 'error')
      .mockImplementation(() => undefined);

    const adapterHost = {
      httpAdapter: {
        getRequestUrl: jest.fn().mockReturnValue('/api/notes/123'),
        getRequestMethod: jest.fn().mockReturnValue('GET'),
        reply,
      },
    } as unknown as HttpAdapterHost;

    filter = new GlobalExceptionFilter(adapterHost);
  });

  afterEach(() => jest.restoreAllMocks());

  const lastCall = () =>
    reply.mock.calls[0] as [unknown, Record<string, unknown>, number];
  const bodyOf = () => lastCall()[1];
  const statusOf = () => lastCall()[2];

  it('passes an HttpException through with its status, message, and path', () => {
    filter.catch(new NotFoundException('Note not found'), host);

    expect(statusOf()).toBe(404);
    expect(bodyOf()).toMatchObject({
      statusCode: 404,
      message: 'Note not found',
      error: 'Not Found',
      path: '/api/notes/123',
    });
    expect(bodyOf().timestamp).toEqual(expect.any(String));
    expect(errorLog).not.toHaveBeenCalled();
  });

  it('preserves a validation-style array message', () => {
    filter.catch(
      new BadRequestException(['a is required', 'b is invalid']),
      host,
    );

    expect(bodyOf().message).toEqual(['a is required', 'b is invalid']);
  });

  it('wraps a raw-string HttpException message', () => {
    filter.catch(new HttpException('teapot', 418), host);

    expect(statusOf()).toBe(418);
    expect(bodyOf().message).toBe('teapot');
  });

  it('maps an unknown error to a generic 500 without leaking details', () => {
    filter.catch(new Error('secret internal detail'), host);

    expect(statusOf()).toBe(500);
    expect(bodyOf().message).toBe('Internal server error');
    expect(JSON.stringify(bodyOf())).not.toContain('secret internal detail');
    expect(errorLog).toHaveBeenCalled();
  });
});
