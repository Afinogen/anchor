"use client";

import { CheckSquare, Square } from "lucide-react";
import type { ReactNode } from "react";
import type { ContentDiff, DiffKind, LineBlock } from "@/features/notes/diff";
import { orderedPreviewMarker, type QuillOp } from "@/features/notes/quill";
import { cn } from "@/lib/utils";

const rowStyles: Record<DiffKind, string> = {
  same: "border-transparent",
  added: "border-emerald-500/70 bg-emerald-500/10",
  removed: "border-rose-500/70 bg-rose-500/10 line-through",
};

const headerStyles: Record<number, string> = {
  1: "text-lg font-semibold",
  2: "text-base font-semibold",
  3: "text-sm font-semibold",
};

const blockStyles: Record<Exclude<LineBlock, null>, string> = {
  blockquote: "italic text-muted-foreground",
  code: "font-mono text-xs",
};

function DiffRow({
  kind,
  className,
  children,
}: {
  kind: DiffKind;
  className?: string;
  children: ReactNode;
}) {
  return (
    <div
      className={cn(
        "rounded-r-sm border-l-2 py-1 pl-3",
        rowStyles[kind],
        className,
      )}
    >
      {children}
    </div>
  );
}

function LineText({ ops }: { ops: QuillOp[] }) {
  return (
    <>
      {ops.map((op, i) => {
        if (typeof op.insert !== "string") return null;
        const attributes = op.attributes;

        return (
          <span
            key={`${i}-${op.insert}`}
            className={cn(
              !!attributes?.bold && "font-semibold",
              !!attributes?.italic && "italic",
              !!attributes?.underline && "underline",
              !!attributes?.strike && "line-through",
              !!attributes?.link && "underline decoration-dotted",
              !!attributes?.code &&
                "rounded bg-foreground/10 px-1 font-mono text-[0.9em]",
            )}
          >
            {op.insert}
          </span>
        );
      })}
    </>
  );
}

interface NoteDiffTitleProps {
  title: string;
  replacedBy: string | null;
}

export function NoteDiffTitle({ title, replacedBy }: NoteDiffTitleProps) {
  if (replacedBy === null) {
    return (
      <h4 className="mb-3 border-l-2 border-transparent pl-3 text-lg font-semibold">
        {title || "Untitled"}
      </h4>
    );
  }

  return (
    <div className="mb-3 flex flex-col gap-px text-lg font-semibold">
      <DiffRow kind="removed">{title || "Untitled"}</DiffRow>
      <DiffRow kind="added">{replacedBy || "Untitled"}</DiffRow>
    </div>
  );
}

interface NoteContentDiffProps {
  diff: ContentDiff;
  className?: string;
}

export function NoteContentDiff({ diff, className }: NoteContentDiffProps) {
  const orderedCounters = new Map<number, number>();

  return (
    <div className={cn("flex flex-col gap-px text-sm", className)}>
      {diff.lines.map((line, i) => {
        if (line.listType === null) {
          orderedCounters.clear();
        } else {
          for (const level of [...orderedCounters.keys()]) {
            if (level > line.indent) orderedCounters.delete(level);
          }
        }

        let marker = "";
        if (line.listType === "ordered") {
          const count = (orderedCounters.get(line.indent) ?? 0) + 1;
          orderedCounters.set(line.indent, count);
          marker = orderedPreviewMarker(count, line.indent);
        } else if (line.listType === "bullet") {
          marker = "•";
        }

        return (
          <DiffRow key={`${line.kind}-${i}-${line.text}`} kind={line.kind}>
            <span
              className={cn(
                "flex items-start gap-2",
                line.header && headerStyles[line.header],
                line.block && blockStyles[line.block],
              )}
              style={
                line.indent ? { paddingLeft: line.indent * 16 } : undefined
              }
            >
              {line.listType === "checked" || line.listType === "unchecked" ? (
                <span className="mt-0.5 shrink-0">
                  {line.listType === "checked" ? (
                    <CheckSquare className="size-4" />
                  ) : (
                    <Square className="size-4 opacity-60" />
                  )}
                </span>
              ) : (
                marker && (
                  <span className="w-3 shrink-0 text-center">{marker}</span>
                )
              )}
              <span className="min-w-0 flex-1 whitespace-pre-wrap break-words">
                <LineText ops={line.ops} />
              </span>
            </span>
          </DiffRow>
        );
      })}
    </div>
  );
}
