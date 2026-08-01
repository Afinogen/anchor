"use client";

import { useMutation } from "@tanstack/react-query";
import { Download, Loader2, Upload } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useTranslation } from "@/lib/i18n";
import { downloadExport } from "../api";
import { ImportDialog } from "./import-dialog";

export function DataImportExportCard() {
  const { t } = useTranslation();
  const [importOpen, setImportOpen] = useState(false);

  const exportMutation = useMutation({
    mutationFn: downloadExport,
    onSuccess: () => {
      toast.success(t("importExport.card.exportSuccess"));
    },
    onError: (error: Error) => {
      toast.error(error.message || t("importExport.card.exportFailed"));
    },
  });

  return (
    <Card className="border-0 shadow-xl bg-card/80 backdrop-blur-sm mb-6">
      <CardHeader className="space-y-1">
        <CardTitle className="text-2xl">
          {t("importExport.card.title")}
        </CardTitle>
        <CardDescription>{t("importExport.card.description")}</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center justify-between gap-4">
          <div className="space-y-0.5">
            <p className="text-sm font-medium">
              {t("importExport.card.exportLabel")}
            </p>
            <p className="text-sm text-muted-foreground">
              {t("importExport.card.exportHint")}
            </p>
          </div>
          <Button
            variant="outline"
            onClick={() => exportMutation.mutate()}
            disabled={exportMutation.isPending}
          >
            {exportMutation.isPending ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                {t("importExport.card.exporting")}
              </>
            ) : (
              <>
                <Download className="h-4 w-4 mr-2" />
                {t("importExport.card.exportButton")}
              </>
            )}
          </Button>
        </div>
        <div className="flex items-center justify-between gap-4">
          <div className="space-y-0.5">
            <p className="text-sm font-medium">
              {t("importExport.card.importLabel")}
            </p>
            <p className="text-sm text-muted-foreground">
              {t("importExport.card.importHint")}
            </p>
          </div>
          <Button variant="outline" onClick={() => setImportOpen(true)}>
            <Upload className="h-4 w-4 mr-2" />
            {t("importExport.card.importButton")}
          </Button>
        </div>
      </CardContent>
      <ImportDialog open={importOpen} onOpenChange={setImportOpen} />
    </Card>
  );
}
