-- CreateEnum
CREATE TYPE "SyncEntityType" AS ENUM ('note', 'tag', 'pin', 'attachments');

-- CreateEnum
CREATE TYPE "SyncOp" AS ENUM ('upsert', 'remove');

-- CreateEnum
CREATE TYPE "RevisionCause" AS ENUM ('edit', 'conflict', 'restore');

-- AlterTable
ALTER TABLE "Note" ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 1;

-- AlterTable
ALTER TABLE "Tag" ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 1;

-- CreateTable
CREATE TABLE "SyncState" (
    "userId" TEXT NOT NULL,
    "lastSeq" BIGINT NOT NULL DEFAULT 0,
    "prunedThroughSeq" BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT "SyncState_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "ChangeLog" (
    "recipientUserId" TEXT NOT NULL,
    "entityType" "SyncEntityType" NOT NULL,
    "entityId" TEXT NOT NULL,
    "op" "SyncOp" NOT NULL,
    "seq" BIGINT NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ChangeLog_pkey" PRIMARY KEY ("recipientUserId","entityType","entityId")
);

-- CreateTable
CREATE TABLE "NoteRevision" (
    "id" TEXT NOT NULL,
    "noteId" TEXT NOT NULL,
    "version" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT,
    "authorUserId" TEXT,
    "cause" "RevisionCause" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "NoteRevision_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ChangeLog_op_updatedAt_idx" ON "ChangeLog"("op", "updatedAt");

-- CreateIndex
CREATE UNIQUE INDEX "ChangeLog_recipientUserId_seq_key" ON "ChangeLog"("recipientUserId", "seq");

-- CreateIndex
CREATE INDEX "NoteRevision_noteId_createdAt_idx" ON "NoteRevision"("noteId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "NoteRevision_createdAt_idx" ON "NoteRevision"("createdAt");

-- AddForeignKey
ALTER TABLE "SyncState" ADD CONSTRAINT "SyncState_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChangeLog" ADD CONSTRAINT "ChangeLog_recipientUserId_fkey" FOREIGN KEY ("recipientUserId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "NoteRevision" ADD CONSTRAINT "NoteRevision_noteId_fkey" FOREIGN KEY ("noteId") REFERENCES "Note"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "NoteRevision" ADD CONSTRAINT "NoteRevision_authorUserId_fkey" FOREIGN KEY ("authorUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Allocate a block of n seqs for a user, returning the last one
-- (block = [result - n + 1, result]). Must run inside the mutation
-- transaction: the SyncState row lock is held to commit, serializing
-- per-user writers so seq order matches commit order per recipient.
CREATE FUNCTION next_sync_seq(uid TEXT, n INT) RETURNS BIGINT AS $$
  INSERT INTO "SyncState" ("userId", "lastSeq")
  VALUES (uid, n)
  ON CONFLICT ("userId") DO UPDATE SET "lastSeq" = "SyncState"."lastSeq" + n
  RETURNING "lastSeq";
$$ LANGUAGE sql;

-- Replace the syncedAt watermark with stateChangedAt, which retention keys off
ALTER TABLE "Note" ADD COLUMN "stateChangedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
UPDATE "Note" SET "stateChangedAt" = "syncedAt";

DROP TRIGGER IF EXISTS note_set_synced_at ON "Note";
DROP FUNCTION IF EXISTS set_note_synced_at();
DROP INDEX IF EXISTS "Note_userId_syncedAt_idx";
ALTER TABLE "Note" DROP COLUMN "syncedAt";

CREATE INDEX "Note_userId_idx" ON "Note"("userId");
CREATE INDEX "Note_state_stateChangedAt_idx" ON "Note"("state", "stateChangedAt");
