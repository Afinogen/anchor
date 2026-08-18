"use client";

import {
  useInfiniteQuery,
  useMutation,
  useQuery,
  useQueryClient,
} from "@tanstack/react-query";
import { ArrowLeft, Loader2, RotateCcw } from "lucide-react";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { toast } from "sonner";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { ConfirmationDialog } from "@/components/ui/confirmation-dialog";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { cn } from "@/lib/utils";
import { getNoteRevision, getNoteRevisions, restoreNoteRevision } from "../api";
import { type ContentDiff, diffNoteContent } from "../diff";
import {
  CURRENT_ENTRY_ID,
  canRestoreRevisions,
  comparisonTargetId,
  currentTimelineEntry,
  groupTimelineByDay,
  historyHasMultipleAuthors,
  revisionAuthorColor,
  revisionAuthorInitial,
  revisionAuthorName,
  revisionDayTime,
  revisionHint,
  revisionLabel,
  revisionsFromPages,
  revisionTime,
  type TimelineEntry,
  timelineEntries,
} from "../history";
import type { Note } from "../types";
import { NoteContentDiff, NoteDiffTitle } from "./note-content-diff";

interface NoteHistorySheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  noteId: string;
  note: Note | null;
  currentUserId: string | null;
  isSaving: boolean;
  onRestored: (note: Note) => void;
}

export function NoteHistorySheet({
  open,
  onOpenChange,
  noteId,
  note,
  currentUserId,
  isSaving,
  onRestored,
}: NoteHistorySheetProps) {
  const queryClient = useQueryClient();
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [confirmOpen, setConfirmOpen] = useState(false);

  useEffect(() => {
    if (!open) {
      setSelectedId(null);
      setConfirmOpen(false);
    }
  }, [open]);

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
    isError,
  } = useInfiniteQuery({
    queryKey: ["note-revisions", noteId],
    queryFn: ({ pageParam }) => getNoteRevisions(noteId, pageParam),
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (page) => page.nextCursor ?? undefined,
    enabled: open,
  });

  const revisions = revisionsFromPages(data?.pages);
  const entries = timelineEntries(revisions);
  const current = currentTimelineEntry(note);
  const showAuthors = historyHasMultipleAuthors(revisions);
  const selected =
    (selectedId === CURRENT_ENTRY_ID
      ? current
      : entries.find((entry) => entry.id === selectedId)) ?? null;
  const selectedRevision = selected?.revision ?? null;

  const {
    data: detail,
    isLoading: detailLoading,
    isError: detailError,
  } = useQuery({
    queryKey: ["note-revisions", noteId, selectedRevision?.id],
    queryFn: () => getNoteRevision(noteId, selectedRevision?.id as string),
    enabled: open && !!selectedRevision,
  });

  const comparedId = selectedRevision
    ? comparisonTargetId(revisions, selectedRevision.id)
    : null;

  const {
    data: comparedDetail,
    isLoading: comparedLoading,
    isError: comparedError,
  } = useQuery({
    queryKey: ["note-revisions", noteId, comparedId],
    queryFn: () => getNoteRevision(noteId, comparedId as string),
    enabled: open && !!comparedId,
  });

  const selectedContent = selectedRevision
    ? (detail?.content ?? null)
    : (note?.content ?? null);
  const selectedTitle = selectedRevision
    ? (detail?.title ?? selected?.title ?? "")
    : (note?.title ?? "");

  const comparedContent =
    selectedRevision && comparedId
      ? (comparedDetail?.content ?? null)
      : (note?.content ?? null);
  const comparedTitle =
    selectedRevision && comparedId
      ? comparedDetail?.title
      : (note?.title ?? "");

  const previewLoading = selectedRevision
    ? detailLoading || (!!comparedId && comparedLoading)
    : false;
  const previewError = selectedRevision
    ? detailError || (!!comparedId && comparedError)
    : false;
  const titleChanged =
    !previewLoading &&
    comparedTitle !== undefined &&
    comparedTitle !== selectedTitle;

  const hasSelection = !!selected;
  const diff = useMemo<ContentDiff | null>(() => {
    if (!hasSelection) return null;
    return diffNoteContent(selectedContent, comparedContent);
  }, [hasSelection, selectedContent, comparedContent]);

  const restoreMutation = useMutation({
    mutationFn: (revisionId: string) => restoreNoteRevision(noteId, revisionId),
    onSuccess: (restored) => {
      onRestored(restored);
      queryClient.setQueryData(["notes", noteId], restored);
      queryClient.invalidateQueries({ queryKey: ["notes"] });
      queryClient.invalidateQueries({ queryKey: ["note-revisions", noteId] });
      setConfirmOpen(false);
      toast.success("This version is back on the note");
      onOpenChange(false);
    },
    onError: () => {
      setConfirmOpen(false);
      toast.error("Failed to restore this version");
    },
  });

  const canRestore = !!selectedRevision && canRestoreRevisions(note);
  const detailSubtitle = entrySubtitle(selected, showAuthors, currentUserId);
  const unchangedNote =
    selectedRevision && !previewLoading && !previewError && !titleChanged
      ? unchangedAgainst(diff, !!comparedId)
      : null;
  const loadMore = useCallback(() => {
    void fetchNextPage();
  }, [fetchNextPage]);

  return (
    <>
      <Sheet open={open} onOpenChange={onOpenChange}>
        <SheetContent className="w-full gap-0 p-0 sm:max-w-lg">
          <SheetHeader className="border-b border-border/50 pr-12">
            {selected ? (
              <div className="flex items-start gap-2">
                <Button
                  variant="ghost"
                  size="icon"
                  className="-ml-2 size-8 shrink-0 rounded-lg"
                  onClick={() => setSelectedId(null)}
                >
                  <ArrowLeft className="size-4" />
                  <span className="sr-only">Back to the version list</span>
                </Button>
                <div className="min-w-0 flex-1">
                  <SheetTitle className="truncate leading-8">
                    {selectedRevision
                      ? revisionDayTime(selected)
                      : "Current version"}
                  </SheetTitle>
                  {detailSubtitle && (
                    <SheetDescription className="text-xs leading-snug">
                      {detailSubtitle}
                    </SheetDescription>
                  )}
                </div>
                {canRestore && (
                  <Button
                    variant="outline"
                    size="sm"
                    className="shrink-0"
                    onClick={() => setConfirmOpen(true)}
                    disabled={
                      restoreMutation.isPending || previewLoading || isSaving
                    }
                  >
                    {restoreMutation.isPending || isSaving ? (
                      <Loader2 className="size-4 animate-spin" />
                    ) : (
                      <>
                        <RotateCcw className="size-3.5" />
                        Restore
                      </>
                    )}
                  </Button>
                )}
              </div>
            ) : (
              <SheetTitle>History</SheetTitle>
            )}
          </SheetHeader>

          {selected ? (
            <EntryPreview
              key={selected.id}
              title={selectedTitle}
              replacedTitle={titleChanged ? (comparedTitle ?? "") : null}
              diff={diff}
              unchangedNote={unchangedNote}
              isLoading={previewLoading}
              isError={previewError}
            />
          ) : (
            <HistoryTimeline
              current={current}
              entries={entries}
              currentUserId={currentUserId}
              showAuthors={showAuthors}
              isLoading={isLoading}
              isError={isError}
              isEmpty={revisions.length === 0}
              hasNextPage={hasNextPage}
              isFetchingNextPage={isFetchingNextPage}
              onSelect={setSelectedId}
              onLoadMore={loadMore}
            />
          )}
        </SheetContent>
      </Sheet>

      <ConfirmationDialog
        open={confirmOpen}
        onOpenChange={setConfirmOpen}
        onConfirm={() =>
          selectedRevision && restoreMutation.mutate(selectedRevision.id)
        }
        title="Restore this version?"
        description="The note goes back to this version. What it says now is kept in the history."
        confirmLabel="Restore"
        icon={
          <div className="flex size-10 items-center justify-center rounded-full bg-primary/10">
            <RotateCcw className="size-5 text-primary" />
          </div>
        }
        isPending={restoreMutation.isPending}
      />
    </>
  );
}

function unchangedAgainst(
  diff: ContentDiff | null,
  comparedWithRevision: boolean,
): string | null {
  if (!diff || diff.added > 0 || diff.removed > 0) return null;
  return comparedWithRevision
    ? "Same text as the version after this one."
    : "Same text as the note as it is now.";
}

function entrySubtitle(
  entry: TimelineEntry | null,
  showAuthors: boolean,
  currentUserId: string | null,
): string {
  if (!entry) return "";
  if (!entry.revision) return revisionDayTime(entry);

  return [
    showAuthors ? revisionAuthorName(entry, currentUserId) : null,
    revisionHint(entry.revision.cause),
  ]
    .filter(Boolean)
    .join(" · ");
}

function EntryAvatar({
  entry,
  currentUserId,
}: {
  entry: TimelineEntry;
  currentUserId: string | null;
}) {
  if (!entry.revision) {
    return (
      <span className="flex size-8 shrink-0 items-center justify-center rounded-full bg-primary/10">
        <span className="size-2 rounded-full bg-primary" />
      </span>
    );
  }

  const { author } = entry;
  const name = revisionAuthorName(entry, currentUserId);

  return (
    <Avatar className="shrink-0">
      {author?.profileImage && (
        <AvatarImage src={author.profileImage} alt={name} />
      )}
      <AvatarFallback
        className={cn("text-xs font-medium", revisionAuthorColor(author))}
      >
        {revisionAuthorInitial(author)}
      </AvatarFallback>
    </Avatar>
  );
}

function EntryRow({
  entry,
  currentUserId,
  showAuthors,
  onSelect,
}: {
  entry: TimelineEntry;
  currentUserId: string | null;
  showAuthors: boolean;
  onSelect: (entryId: string) => void;
}) {
  const { revision } = entry;
  const subtitle = revision
    ? [
        revision.cause === "edit" ? null : revisionLabel(revision.cause),
        showAuthors ? revisionAuthorName(entry, currentUserId) : null,
      ]
        .filter(Boolean)
        .join(" · ")
    : revisionDayTime(entry);

  return (
    <button
      type="button"
      onClick={() => onSelect(entry.id)}
      className="flex w-full items-center gap-3 px-4 py-3 text-left transition-colors hover:bg-muted/50"
    >
      {showAuthors && (
        <EntryAvatar entry={entry} currentUserId={currentUserId} />
      )}
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-medium">
          {revision ? revisionTime(entry) : "Current version"}
        </p>
        {subtitle && (
          <p className="truncate text-xs text-muted-foreground">{subtitle}</p>
        )}
      </div>
    </button>
  );
}

interface HistoryTimelineProps {
  current: TimelineEntry | null;
  entries: TimelineEntry[];
  currentUserId: string | null;
  showAuthors: boolean;
  isLoading: boolean;
  isError: boolean;
  isEmpty: boolean;
  hasNextPage: boolean;
  isFetchingNextPage: boolean;
  onSelect: (entryId: string) => void;
  onLoadMore: () => void;
}

function HistoryTimeline({
  current,
  entries,
  currentUserId,
  showAuthors,
  isLoading,
  isError,
  isEmpty,
  hasNextPage,
  isFetchingNextPage,
  onSelect,
  onLoadMore,
}: HistoryTimelineProps) {
  const sentinel = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const node = sentinel.current;
    if (!node || !hasNextPage || isFetchingNextPage) return;

    const observer = new IntersectionObserver((observed) => {
      if (observed.some((entry) => entry.isIntersecting)) onLoadMore();
    });
    observer.observe(node);
    return () => observer.disconnect();
  }, [hasNextPage, isFetchingNextPage, onLoadMore]);

  return (
    <div className="flex-1 overflow-y-auto">
      {current && (
        <div className="border-b border-border/50 bg-muted/30">
          <EntryRow
            entry={current}
            currentUserId={currentUserId}
            showAuthors={showAuthors}
            onSelect={onSelect}
          />
        </div>
      )}

      {isLoading && (
        <div className="flex justify-center py-6">
          <Loader2 className="size-5 animate-spin text-muted-foreground" />
        </div>
      )}

      {isError && (
        <p className="p-4 text-sm text-muted-foreground">
          Could not load this note&apos;s history.
        </p>
      )}

      {groupTimelineByDay(entries).map((day) => (
        <section key={day.key}>
          <h3 className="sticky top-0 z-10 bg-background/95 px-4 py-2 text-xs font-medium text-muted-foreground backdrop-blur-sm">
            {day.label}
          </h3>
          <ul className="divide-y divide-border/50">
            {day.entries.map((entry) => (
              <li key={entry.id}>
                <EntryRow
                  entry={entry}
                  currentUserId={currentUserId}
                  showAuthors={showAuthors}
                  onSelect={onSelect}
                />
              </li>
            ))}
          </ul>
        </section>
      ))}

      {hasNextPage && (
        <div ref={sentinel} className="flex justify-center py-4">
          {isFetchingNextPage && (
            <Loader2 className="size-4 animate-spin text-muted-foreground" />
          )}
        </div>
      )}

      {isEmpty && !isLoading && !isError && (
        <p className="p-4 text-sm text-muted-foreground">
          No earlier versions yet.
        </p>
      )}

      {!isEmpty && !hasNextPage && (
        <p className="px-4 py-3 text-xs text-muted-foreground">
          Edits older than 90 days are removed.
        </p>
      )}
    </div>
  );
}

interface EntryPreviewProps {
  title: string;
  replacedTitle: string | null;
  diff: ContentDiff | null;
  unchangedNote: string | null;
  isLoading: boolean;
  isError: boolean;
}

function EntryPreview({
  title,
  replacedTitle,
  diff,
  unchangedNote,
  isLoading,
  isError,
}: EntryPreviewProps) {
  if (isLoading) {
    return (
      <div className="flex flex-1 justify-center py-8">
        <Loader2 className="size-5 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (isError || !diff) {
    return (
      <div className="flex-1 px-4 py-3">
        <p className="text-sm text-muted-foreground">
          Could not load this version.
        </p>
      </div>
    );
  }

  return (
    <div className="flex-1 overflow-y-auto px-4 py-3">
      {unchangedNote && (
        <p className="mb-3 pl-3 text-xs text-muted-foreground">
          {unchangedNote}
        </p>
      )}
      <NoteDiffTitle title={title} replacedBy={replacedTitle} />
      {diff.lines.length === 0 ? (
        <p className="pl-3 text-sm text-muted-foreground">
          This version has no text.
        </p>
      ) : (
        <NoteContentDiff diff={diff} />
      )}
    </div>
  );
}
