"use client";

import {
  AlertTriangle,
  CheckCircle2,
  ChevronDown,
  FileArchive,
  FileText,
  Loader2,
  type LucideIcon,
  Paperclip,
  Tag as TagIcon,
  Upload,
} from "lucide-react";
import { useCallback, useRef, useState } from "react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { type TranslationKey, useTranslation } from "@/lib/i18n";
import { cn } from "@/lib/utils";
import { useImport } from "../hooks/use-import";

interface ImportDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function ImportDialog({ open, onOpenChange }: ImportDialogProps) {
  const { t } = useTranslation();
  const {
    step,
    parsed,
    isDetecting,
    pickError,
    runError,
    progress,
    report,
    isRunning,
    skipExisting,
    setSkipExisting,
    selectFile,
    start,
    retry,
    reset,
  } = useImport();

  const handleOpenChange = (next: boolean) => {
    // Don't allow closing mid-import
    if (!next && isRunning) return;
    if (!next) reset();
    onOpenChange(next);
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>{t("importExport.dialog.title")}</DialogTitle>
          <DialogDescription>
            {t("importExport.dialog.description")}
          </DialogDescription>
        </DialogHeader>

        {step === "pick" && (
          <PickStep
            isDetecting={isDetecting}
            error={pickError}
            onFile={selectFile}
          />
        )}
        {step === "preview" && parsed && (
          <PreviewStep
            parsed={parsed}
            skipExisting={skipExisting}
            onSkipExistingChange={setSkipExisting}
            onConfirm={start}
            onCancel={() => handleOpenChange(false)}
          />
        )}
        {step === "running" && (
          <RunningStep progress={progress} error={runError} onRetry={retry} />
        )}
        {step === "report" && report && (
          <ReportStep report={report} onClose={() => handleOpenChange(false)} />
        )}
      </DialogContent>
    </Dialog>
  );
}

function PickStep({
  isDetecting,
  error,
  onFile,
}: {
  isDetecting: boolean;
  error: string | null;
  onFile: (file: File) => void;
}) {
  const { t } = useTranslation();
  const inputRef = useRef<HTMLInputElement>(null);
  const [isDragging, setIsDragging] = useState(false);

  const handleFiles = useCallback(
    (files: FileList | null) => {
      const file = files?.[0];
      if (file) onFile(file);
    },
    [onFile],
  );

  return (
    <div className="space-y-3">
      <div
        className={cn(
          "border-2 border-dashed rounded-lg p-8 flex flex-col items-center gap-3 cursor-pointer",
          "text-muted-foreground text-sm transition-colors duration-150",
          isDragging
            ? "border-primary bg-primary/5 text-primary"
            : "border-border/60 hover:border-border hover:bg-muted/30",
        )}
        onDragOver={(e) => {
          e.preventDefault();
          setIsDragging(true);
        }}
        onDragLeave={() => setIsDragging(false)}
        onDrop={(e) => {
          e.preventDefault();
          setIsDragging(false);
          handleFiles(e.dataTransfer.files);
        }}
        onClick={() => inputRef.current?.click()}
      >
        {isDetecting ? (
          <Loader2 className="h-8 w-8 animate-spin" />
        ) : (
          <FileArchive className="h-8 w-8" />
        )}
        <span className="text-center">
          {isDetecting
            ? t("importExport.pick.reading")
            : t("importExport.pick.dropzone")}
        </span>
        <input
          ref={inputRef}
          type="file"
          accept=".zip,application/zip"
          className="hidden"
          onChange={(e) => handleFiles(e.target.files)}
        />
      </div>
      {error && (
        <p className="text-sm text-destructive flex items-start gap-2">
          <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" />
          {error}
        </p>
      )}
    </div>
  );
}

function PreviewStep({
  parsed,
  skipExisting,
  onSkipExistingChange,
  onConfirm,
  onCancel,
}: {
  parsed: NonNullable<ReturnType<typeof useImport>["parsed"]>;
  skipExisting: boolean;
  onSkipExistingChange: (value: boolean) => void;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  const { t } = useTranslation();
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2 text-sm text-muted-foreground">
        <FileArchive className="h-4 w-4 shrink-0" />
        <span>{t("importExport.preview.detectedFormat")}</span>
        <Badge variant="secondary">{parsed.formatLabel}</Badge>
      </div>
      <div className="grid grid-cols-3 gap-2">
        <PreviewStat
          icon={FileText}
          value={parsed.notes.length}
          labelKey="importExport.preview.noteCount"
        />
        <PreviewStat
          icon={TagIcon}
          value={parsed.tags.length}
          labelKey="importExport.preview.tagCount"
        />
        <PreviewStat
          icon={Paperclip}
          value={parsed.attachmentCount}
          labelKey="importExport.preview.attachmentCount"
        />
      </div>
      {parsed.skipped.length > 0 && (
        <SkippedList
          title={t("importExport.preview.skippedTitle", {
            count: parsed.skipped.length,
          })}
          items={parsed.skipped}
        />
      )}
      {/* Only Anchor backups carry note ids, so only they can skip existing notes */}
      {parsed.formatId === "anchor" && (
        <div className="flex items-center gap-2">
          <Checkbox
            id="skip-existing-notes"
            checked={skipExisting}
            onCheckedChange={(checked) =>
              onSkipExistingChange(checked === true)
            }
          />
          <Label
            htmlFor="skip-existing-notes"
            className="text-sm font-normal leading-snug cursor-pointer"
          >
            {t("importExport.preview.skipExisting")}
          </Label>
        </div>
      )}
      <DialogFooter>
        <Button variant="outline" onClick={onCancel}>
          {t("common.cancel")}
        </Button>
        <Button onClick={onConfirm}>
          <Upload className="h-4 w-4 mr-2" />
          {t("importExport.preview.importButton", {
            count: parsed.notes.length,
          })}
        </Button>
      </DialogFooter>
    </div>
  );
}

function PreviewStat({
  icon: Icon,
  value,
  labelKey,
}: {
  icon: LucideIcon;
  value: number;
  labelKey: TranslationKey;
}) {
  const { t } = useTranslation();
  return (
    <div className="flex flex-col items-center gap-0.5 rounded-lg border border-border/60 bg-muted/30 p-3">
      <Icon className="h-4 w-4 text-muted-foreground" />
      <span className="text-xl font-semibold leading-tight">{value}</span>
      <span className="text-xs text-muted-foreground text-center">
        {t(labelKey, { count: value })}
      </span>
    </div>
  );
}

function RunningStep({
  progress,
  error,
  onRetry,
}: {
  progress: {
    phase: "notes" | "attachments";
    done: number;
    total: number;
  } | null;
  error: string | null;
  onRetry: () => void;
}) {
  const { t } = useTranslation();
  const percent =
    progress && progress.total > 0
      ? Math.round((progress.done / progress.total) * 100)
      : 0;
  const label =
    progress?.phase === "attachments"
      ? t("importExport.running.uploadingAttachments", {
          done: progress.done,
          total: progress.total,
        })
      : t("importExport.running.importingNotes", {
          done: progress?.done ?? 0,
          total: progress?.total ?? 0,
        });

  return (
    <div className="space-y-4">
      <div className="space-y-2">
        <div className="flex items-center justify-between text-sm text-muted-foreground">
          <span className="flex items-center gap-2">
            {!error && <Loader2 className="h-4 w-4 animate-spin" />}
            {label}
          </span>
          <span>{percent}%</span>
        </div>
        <div className="h-2 w-full rounded-full bg-muted overflow-hidden">
          <div
            className="h-full rounded-full bg-primary transition-all duration-300"
            style={{ width: `${percent}%` }}
          />
        </div>
      </div>
      {error && (
        <div className="space-y-3">
          <p className="text-sm text-destructive flex items-start gap-2">
            <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" />
            {error}
          </p>
          <DialogFooter>
            <Button onClick={onRetry}>{t("importExport.running.retry")}</Button>
          </DialogFooter>
        </div>
      )}
      {!error && (
        <p className="text-xs text-muted-foreground">
          {t("importExport.running.keepOpen")}
        </p>
      )}
    </div>
  );
}

function ReportStep({
  report,
  onClose,
}: {
  report: NonNullable<ReturnType<typeof useImport>["report"]>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const summary: string[] = [];
  if (report.created)
    summary.push(t("importExport.report.created", { count: report.created }));
  if (report.remapped)
    summary.push(t("importExport.report.remapped", { count: report.remapped }));
  if (report.skipped)
    summary.push(t("importExport.report.skipped", { count: report.skipped }));
  if (report.failed)
    summary.push(t("importExport.report.failed", { count: report.failed }));
  if (report.attachmentsUploaded)
    summary.push(
      t("importExport.report.attachmentsUploaded", {
        count: report.attachmentsUploaded,
      }),
    );
  if (report.attachmentsFailed)
    summary.push(
      t("importExport.report.attachmentsFailed", {
        count: report.attachmentsFailed,
      }),
    );

  return (
    <div className="space-y-4">
      <p className="text-sm flex items-start gap-2">
        {report.failed || report.attachmentsFailed ? (
          <AlertTriangle className="h-4 w-4 mt-0.5 text-amber-500 shrink-0" />
        ) : (
          <CheckCircle2 className="h-4 w-4 mt-0.5 text-green-500 shrink-0" />
        )}
        {summary.join(" · ") || t("importExport.report.nothing")}
      </p>
      {report.issues.length > 0 && (
        <SkippedList
          title={t("importExport.report.issuesTitle", {
            count: report.issues.length,
          })}
          items={report.issues}
        />
      )}
      <p className="text-xs text-muted-foreground">
        {t("importExport.report.trashNote")}
      </p>
      <DialogFooter>
        <Button onClick={onClose}>{t("importExport.report.done")}</Button>
      </DialogFooter>
    </div>
  );
}

function SkippedList({
  title,
  items,
}: {
  title: string;
  items: { item: string; reason: string }[];
}) {
  return (
    <Collapsible className="rounded-lg border border-amber-500/30 bg-amber-500/5 px-3 py-2">
      <CollapsibleTrigger className="group flex w-full items-center gap-2 text-sm text-amber-600 dark:text-amber-400 transition-opacity hover:opacity-80">
        <AlertTriangle className="h-4 w-4 shrink-0" />
        <span className="flex-1 text-left">{title}</span>
        <ChevronDown className="h-4 w-4 shrink-0 transition-transform group-data-[state=open]:rotate-180" />
      </CollapsibleTrigger>
      <CollapsibleContent>
        <ul className="mt-2 max-h-40 overflow-y-auto space-y-1 text-xs text-muted-foreground">
          {items.map((entry, index) => (
            <li key={`${entry.item}-${index}`} className="truncate">
              <span className="font-medium">{entry.item}</span> — {entry.reason}
            </li>
          ))}
        </ul>
      </CollapsibleContent>
    </Collapsible>
  );
}
