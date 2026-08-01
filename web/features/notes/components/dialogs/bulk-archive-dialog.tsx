"use client";

import { Archive } from "lucide-react";
import { ConfirmationDialog } from "@/components/ui/confirmation-dialog";
import { useTranslation } from "@/lib/i18n";

interface BulkArchiveDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onConfirm: () => void;
  count: number;
  isPending?: boolean;
}

export function BulkArchiveDialog({
  open,
  onOpenChange,
  onConfirm,
  count,
  isPending = false,
}: BulkArchiveDialogProps) {
  const { t } = useTranslation();
  return (
    <ConfirmationDialog
      open={open}
      onOpenChange={onOpenChange}
      onConfirm={onConfirm}
      title={
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
            <Archive className="h-5 w-5 text-primary" />
          </div>
          {t("notes.dialogs.bulkArchiveTitle")}
        </div>
      }
      description={t("notes.dialogs.bulkArchiveDesc", { count })}
      confirmLabel={t("notes.dialogs.archive")}
      variant="default"
      isPending={isPending}
    />
  );
}
