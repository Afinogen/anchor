"use client";

import { Archive, ArchiveRestore, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { useTranslation } from "@/lib/i18n";

interface ArchiveDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  isArchived: boolean;
  onConfirm: () => void;
  isPending?: boolean;
}

export function ArchiveDialog({
  open,
  onOpenChange,
  isArchived,
  onConfirm,
  isPending = false,
}: ArchiveDialogProps) {
  const { t } = useTranslation();
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
              {isArchived ? (
                <ArchiveRestore className="h-5 w-5 text-primary" />
              ) : (
                <Archive className="h-5 w-5 text-primary" />
              )}
            </div>
            {isArchived
              ? t("notes.dialogs.unarchiveTitle")
              : t("notes.dialogs.archiveTitle")}
          </DialogTitle>
          <DialogDescription className="pt-2">
            {isArchived
              ? t("notes.dialogs.unarchiveDesc")
              : t("notes.dialogs.archiveDesc")}
          </DialogDescription>
        </DialogHeader>
        <DialogFooter className="gap-2 sm:gap-0">
          <Button variant="ghost" onClick={() => onOpenChange(false)}>
            {t("common.cancel")}
          </Button>
          <Button onClick={onConfirm} disabled={isPending}>
            {isPending ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : isArchived ? (
              t("notes.dialogs.unarchive")
            ) : (
              t("notes.dialogs.archive")
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
