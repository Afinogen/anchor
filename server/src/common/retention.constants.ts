// Retention sweeps run one chunk per transaction. Each transaction holds a
// sync lock for every user it touches, so the chunk bounds how long anyone's
// writes can wait behind the nightly job.
export const RETENTION_CHUNK_SIZE = 200;
