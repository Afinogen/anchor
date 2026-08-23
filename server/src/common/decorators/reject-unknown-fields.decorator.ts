import 'reflect-metadata';

const REJECT_UNKNOWN_FIELDS = Symbol('rejectUnknownFields');

/** Applies to the whole object graph, so it belongs on the top-level DTO. */
export const RejectUnknownFields = (): ClassDecorator => (target) => {
  Reflect.defineMetadata(REJECT_UNKNOWN_FIELDS, true, target);
};

export const rejectsUnknownFields = (metatype: unknown): boolean => {
  if (typeof metatype !== 'function') return false;
  const flag: unknown = Reflect.getMetadata(REJECT_UNKNOWN_FIELDS, metatype);
  return flag === true;
};
