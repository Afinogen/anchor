"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { format } from "date-fns";
import {
  AlertTriangle,
  CheckCircle,
  Clock,
  FileText,
  KeyRound,
  Loader2,
  Lock,
  MoreVertical,
  Plus,
  Tag,
  UserPlus,
  Users,
  XCircle,
} from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group";
import {
  AdminGuard,
  type AdminUser,
  approveUser,
  type CreateUserDto,
  createUser,
  deleteUser,
  getAdminStats,
  getOidcSettings,
  getPendingUsers,
  getRegistrationSettings,
  getUsers,
  type RegistrationMode,
  rejectUser,
  resetPassword,
  type UpdateOidcSettingsDto,
  type UpdateUserDto,
  updateOidcSettings,
  updateRegistrationMode,
  updateUser,
} from "@/features/admin";
import { useAuth } from "@/features/auth";
import { useTranslation } from "@/lib/i18n";

export default function AdminPage() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const { user: currentUser } = useAuth();
  const [userDialogOpen, setUserDialogOpen] = useState(false);
  const [resetPasswordDialogOpen, setResetPasswordDialogOpen] = useState(false);
  const [deleteUserDialogOpen, setDeleteUserDialogOpen] = useState(false);
  const [rejectUserDialogOpen, setRejectUserDialogOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<AdminUser | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState<
    CreateUserDto & { isAdmin?: boolean }
  >({
    email: "",
    password: "",
    name: "",
  });
  const [resetPasswordResult, setResetPasswordResult] = useState<string | null>(
    null,
  );
  const [oidcFormData, setOidcFormData] =
    useState<UpdateOidcSettingsDto | null>(null);
  const [oidcClearSecretRequested, setOidcClearSecretRequested] =
    useState(false);

  const { data: stats, isLoading: statsLoading } = useQuery({
    queryKey: ["admin", "stats"],
    queryFn: getAdminStats,
  });

  const { data: registrationSettings, isLoading: registrationSettingsLoading } =
    useQuery({
      queryKey: ["admin", "settings", "registration"],
      queryFn: getRegistrationSettings,
    });

  const { data: oidcSettings, isLoading: oidcSettingsLoading } = useQuery({
    queryKey: ["admin", "settings", "oidc"],
    queryFn: getOidcSettings,
  });

  // Initialize form data when settings are loaded
  useEffect(() => {
    if (oidcSettings) {
      setOidcFormData({
        enabled: oidcSettings.enabled,
        providerName: oidcSettings.providerName,
        issuerUrl: oidcSettings.issuerUrl || "",
        clientId: oidcSettings.clientId || "",
        clientSecret: oidcSettings.hasClientSecret ? "" : "",
        disableInternalAuth: oidcSettings.disableInternalAuth,
      });
      setOidcClearSecretRequested(false);
    }
  }, [oidcSettings]);

  const { data: pendingUsers = [], isLoading: pendingUsersLoading } = useQuery({
    queryKey: ["admin", "users", "pending"],
    queryFn: getPendingUsers,
  });

  const { data: usersData, isLoading: usersLoading } = useQuery({
    queryKey: ["admin", "users"],
    queryFn: () => getUsers(),
  });

  const updateRegistrationModeMutation = useMutation({
    mutationFn: updateRegistrationMode,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "settings"] });
      queryClient.invalidateQueries({
        queryKey: ["admin", "users", "pending"],
      });
      toast.success(t("admin.registrationModeUpdated"));
    },
    onError: (error: Error) => {
      toast.error(error.message || t("admin.registrationModeFailed"));
    },
  });

  const updateOidcSettingsMutation = useMutation({
    mutationFn: updateOidcSettings,
    onSuccess: () => {
      setOidcClearSecretRequested(false);
      queryClient.invalidateQueries({
        queryKey: ["admin", "settings", "oidc"],
      });
      queryClient.invalidateQueries({ queryKey: ["oidc-config"] });
      toast.success(t("admin.oidcUpdated"));
    },
    onError: (error: Error) => {
      toast.error(error.message || t("admin.oidcFailed"));
    },
  });

  const oidcFormHasChanges =
    !!oidcSettings &&
    !!oidcFormData &&
    !oidcSettings.isLocked &&
    (oidcFormData.enabled !== oidcSettings.enabled ||
      (oidcFormData.providerName ?? "") !== (oidcSettings.providerName ?? "") ||
      (oidcFormData.issuerUrl ?? "") !== (oidcSettings.issuerUrl ?? "") ||
      (oidcFormData.clientId ?? "") !== (oidcSettings.clientId ?? "") ||
      (oidcFormData.disableInternalAuth ?? false) !==
        oidcSettings.disableInternalAuth ||
      oidcClearSecretRequested ||
      (!!oidcFormData.clientSecret && oidcFormData.clientSecret.trim() !== ""));

  const handleSaveOidcSettings = () => {
    if (!oidcFormData) return;

    // Validate required fields when enabling
    if (oidcFormData.enabled) {
      if (!oidcFormData.issuerUrl?.trim() || !oidcFormData.clientId?.trim()) {
        toast.error(t("admin.oidcRequiredFields"));
        return;
      }
    }

    const settingsToSave: UpdateOidcSettingsDto = { ...oidcFormData };

    if (oidcClearSecretRequested) {
      settingsToSave.clearClientSecret = true;
      delete settingsToSave.clientSecret;
    } else if (
      oidcSettings?.hasClientSecret &&
      (!oidcFormData.clientSecret || oidcFormData.clientSecret.trim() === "")
    ) {
      // Leave existing secret unchanged
      delete settingsToSave.clientSecret;
    }

    updateOidcSettingsMutation.mutate(settingsToSave);
  };

  const approveUserMutation = useMutation({
    mutationFn: approveUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
      queryClient.invalidateQueries({
        queryKey: ["admin", "users", "pending"],
      });
      queryClient.invalidateQueries({ queryKey: ["admin", "stats"] });
      toast.success(t("admin.userApproved"));
    },
    onError: (error: Error) => {
      toast.error(error.message || t("admin.userApproveFailed"));
    },
  });

  const rejectUserMutation = useMutation({
    mutationFn: rejectUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
      queryClient.invalidateQueries({
        queryKey: ["admin", "users", "pending"],
      });
      queryClient.invalidateQueries({ queryKey: ["admin", "stats"] });
      setRejectUserDialogOpen(false);
      setSelectedUser(null);
      toast.success(t("admin.userRejected"));
    },
    onError: (error: Error) => {
      toast.error(error.message || t("admin.userRejectFailed"));
    },
  });

  const createUserMutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
      queryClient.invalidateQueries({ queryKey: ["admin", "stats"] });
      setUserDialogOpen(false);
      setFormData({ email: "", password: "", name: "" });
      setIsEditing(false);
      toast.success(t("admin.userCreated"));
    },
    onError: (error: Error) => {
      toast.error(error.message || t("admin.userCreateFailed"));
    },
  });

  const updateUserMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateUserDto }) =>
      updateUser(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
      setUserDialogOpen(false);
      setSelectedUser(null);
      setFormData({ email: "", password: "", name: "" });
      setIsEditing(false);
      toast.success(t("admin.userUpdated"));
    },
    onError: (error: Error) => {
      toast.error(error.message || t("admin.userUpdateFailed"));
    },
  });

  const deleteUserMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
      queryClient.invalidateQueries({ queryKey: ["admin", "stats"] });
      setDeleteUserDialogOpen(false);
      setSelectedUser(null);
      toast.success(t("admin.userDeleted"));
    },
    onError: (error: Error) => {
      toast.error(error.message || t("admin.userDeleteFailed"));
    },
  });

  const resetPasswordMutation = useMutation({
    mutationFn: (id: string) => resetPassword(id),
    onSuccess: (data) => {
      setResetPasswordResult(data.newPassword || null);
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
      toast.success(t("admin.passwordResetSuccess"));
    },
    onError: (error: Error) => {
      toast.error(error.message || t("admin.passwordResetFailed"));
    },
  });

  const handleCreateUser = () => {
    setSelectedUser(null);
    setIsEditing(false);
    setFormData({ email: "", password: "", name: "" });
    setUserDialogOpen(true);
  };

  const handleEditUser = (user: AdminUser) => {
    setSelectedUser(user);
    setIsEditing(true);
    setFormData({
      email: user.email,
      password: "",
      name: user.name || "",
      isAdmin: user.isAdmin,
    });
    setUserDialogOpen(true);
  };

  const handleDeleteUser = (user: AdminUser) => {
    setSelectedUser(user);
    setDeleteUserDialogOpen(true);
  };

  const handleDeleteConfirm = () => {
    if (selectedUser) {
      deleteUserMutation.mutate(selectedUser.id);
    }
  };

  const handleRejectUser = (user: AdminUser) => {
    setSelectedUser(user);
    setRejectUserDialogOpen(true);
  };

  const handleRejectConfirm = () => {
    if (selectedUser) {
      rejectUserMutation.mutate(selectedUser.id);
    }
  };

  const handleResetPassword = (user: AdminUser) => {
    setSelectedUser(user);
    setResetPasswordResult(null);
    setResetPasswordDialogOpen(true);
  };

  const handleSubmitUser = () => {
    if (isEditing && selectedUser) {
      updateUserMutation.mutate({
        id: selectedUser.id,
        data: {
          email: formData.email,
          name: formData.name,
          isAdmin: formData.isAdmin,
        },
      });
    } else {
      if (!formData.password) {
        toast.error(t("admin.passwordRequired"));
        return;
      }
      createUserMutation.mutate(formData);
    }
  };

  const handleResetPasswordSubmit = () => {
    if (selectedUser) {
      resetPasswordMutation.mutate(selectedUser.id);
    }
  };

  const copyPassword = () => {
    if (resetPasswordResult) {
      navigator.clipboard.writeText(resetPasswordResult);
      toast.success(t("admin.passwordCopied"));
    }
  };

  return (
    <AdminGuard>
      <div className="container mx-auto p-6 space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-serif font-bold">
              {t("admin.title")}
            </h1>
            <p className="text-muted-foreground mt-1">{t("admin.subtitle")}</p>
          </div>
        </div>

        {/* Statistics */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                {t("admin.totalUsers")}
              </CardTitle>
              <Users className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {statsLoading ? "..." : stats?.totalUsers || 0}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                {t("admin.totalNotes")}
              </CardTitle>
              <FileText className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {statsLoading ? "..." : stats?.totalNotes || 0}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                {t("admin.totalTags")}
              </CardTitle>
              <Tag className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {statsLoading ? "..." : stats?.totalTags || 0}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Registration Settings */}
        <Card>
          <CardHeader>
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md border bg-muted/50">
                <UserPlus className="h-5 w-5 text-muted-foreground" />
              </div>
              <div>
                <CardTitle>{t("admin.registrationSettings")}</CardTitle>
                <CardDescription className="mt-1">
                  {t("admin.registrationSettingsDesc")}
                </CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent className="space-y-6">
            {registrationSettingsLoading ? (
              <div className="flex items-center justify-center py-8">
                <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
              </div>
            ) : registrationSettings ? (
              <>
                {registrationSettings.isLocked && (
                  <div className="flex items-start gap-2 p-3 border rounded-lg bg-muted/50">
                    <Lock className="h-3.5 w-3.5 mt-0.5 text-muted-foreground shrink-0" />
                    <p className="text-sm text-muted-foreground">
                      {t("admin.registrationLockedNote")}
                    </p>
                  </div>
                )}
                <div className="space-y-3">
                  <div className="flex flex-col gap-2 md:flex-row md:items-center md:gap-4">
                    <Label className="w-36 shrink-0">
                      {t("admin.registrationMode")}
                    </Label>
                    <ToggleGroup
                      type="single"
                      value={registrationSettings.mode}
                      onValueChange={(value) => {
                        if (value && !registrationSettings.isLocked) {
                          updateRegistrationModeMutation.mutate({
                            mode: value as RegistrationMode,
                          });
                        }
                      }}
                      disabled={
                        registrationSettings.isLocked ||
                        updateRegistrationModeMutation.isPending
                      }
                      className="justify-start rounded-md border"
                    >
                      <ToggleGroupItem
                        value="enabled"
                        aria-label={t("admin.enabled")}
                      >
                        {t("admin.enabled")}
                      </ToggleGroupItem>
                      <ToggleGroupItem
                        value="review"
                        aria-label={t("admin.requireReview")}
                      >
                        {t("admin.requireReview")}
                      </ToggleGroupItem>
                      <ToggleGroupItem
                        value="disabled"
                        aria-label={t("admin.disabled")}
                      >
                        {t("admin.disabled")}
                      </ToggleGroupItem>
                    </ToggleGroup>
                  </div>
                  <p className="text-sm text-muted-foreground">
                    {registrationSettings.mode === "disabled" &&
                      t("admin.modeDisabledDesc")}
                    {registrationSettings.mode === "enabled" &&
                      t("admin.modeEnabledDesc")}
                    {registrationSettings.mode === "review" &&
                      t("admin.modeReviewDesc")}
                  </p>
                </div>
              </>
            ) : null}
          </CardContent>
        </Card>

        {/* OIDC Settings */}
        <Card>
          <CardHeader>
            <div className="flex items-start justify-between gap-4">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md border bg-muted/50">
                  <KeyRound className="h-5 w-5 text-muted-foreground" />
                </div>
                <div>
                  <CardTitle>{t("admin.oidcTitle")}</CardTitle>
                  <CardDescription className="mt-1">
                    {t("admin.oidcDesc")}
                  </CardDescription>
                </div>
              </div>
              {oidcSettings && (
                <Switch
                  id="oidc-enabled"
                  checked={oidcFormData?.enabled ?? false}
                  onCheckedChange={(checked) => {
                    if (!oidcSettings.isLocked && oidcFormData) {
                      setOidcFormData({ ...oidcFormData, enabled: checked });
                    }
                  }}
                  disabled={
                    oidcSettings.isLocked ||
                    updateOidcSettingsMutation.isPending
                  }
                />
              )}
            </div>
          </CardHeader>
          <CardContent className="space-y-6">
            {oidcSettingsLoading ? (
              <div className="flex items-center justify-center py-8">
                <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
              </div>
            ) : oidcSettings ? (
              <>
                {oidcSettings.isLocked && (
                  <div className="flex items-start gap-2 p-3 border rounded-lg bg-muted/50">
                    <Lock className="h-3.5 w-3.5 mt-0.5 text-muted-foreground shrink-0" />
                    <p className="text-sm text-muted-foreground">
                      {t("admin.oidcLockedNote")}
                    </p>
                  </div>
                )}

                {oidcFormData?.enabled && (
                  <>
                    <div className="grid gap-4 sm:grid-cols-2">
                      <div className="space-y-2 sm:col-span-2">
                        <Label htmlFor="oidc-provider-name">
                          {t("admin.providerName")}
                        </Label>
                        <Input
                          id="oidc-provider-name"
                          value={oidcFormData?.providerName || ""}
                          onChange={(e) => {
                            if (!oidcSettings.isLocked && oidcFormData) {
                              setOidcFormData({
                                ...oidcFormData,
                                providerName: e.target.value,
                              });
                            }
                          }}
                          disabled={
                            oidcSettings.isLocked ||
                            updateOidcSettingsMutation.isPending
                          }
                          placeholder={t("admin.providerNamePlaceholder")}
                        />
                        <p className="text-xs text-muted-foreground">
                          {t("admin.providerNameHint", {
                            provider: oidcFormData?.providerName || "Provider",
                          })}
                        </p>
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="oidc-issuer-url">
                          {t("admin.issuerUrl")}{" "}
                          <span className="text-destructive">*</span>
                        </Label>
                        <Input
                          id="oidc-issuer-url"
                          value={oidcFormData?.issuerUrl || ""}
                          onChange={(e) => {
                            if (!oidcSettings.isLocked && oidcFormData) {
                              setOidcFormData({
                                ...oidcFormData,
                                issuerUrl: e.target.value,
                              });
                            }
                          }}
                          disabled={
                            oidcSettings.isLocked ||
                            updateOidcSettingsMutation.isPending
                          }
                          placeholder={t("admin.issuerUrlPlaceholder")}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="oidc-client-id">
                          {t("admin.clientId")}{" "}
                          <span className="text-destructive">*</span>
                        </Label>
                        <Input
                          id="oidc-client-id"
                          value={oidcFormData?.clientId || ""}
                          onChange={(e) => {
                            if (!oidcSettings.isLocked && oidcFormData) {
                              setOidcFormData({
                                ...oidcFormData,
                                clientId: e.target.value,
                              });
                            }
                          }}
                          disabled={
                            oidcSettings.isLocked ||
                            updateOidcSettingsMutation.isPending
                          }
                          placeholder={t("admin.clientIdPlaceholder")}
                        />
                      </div>
                      <div className="space-y-2 sm:col-span-2">
                        <Label htmlFor="oidc-client-secret">
                          {t("admin.clientSecret")}
                        </Label>
                        <div className="flex gap-2">
                          <Input
                            id="oidc-client-secret"
                            type="password"
                            autoComplete="off"
                            value={
                              oidcClearSecretRequested
                                ? ""
                                : (oidcFormData?.clientSecret ?? "")
                            }
                            onChange={(e) => {
                              if (!oidcSettings.isLocked && oidcFormData) {
                                setOidcClearSecretRequested(false);
                                setOidcFormData({
                                  ...oidcFormData,
                                  clientSecret: e.target.value,
                                });
                              }
                            }}
                            disabled={
                              oidcSettings.isLocked ||
                              updateOidcSettingsMutation.isPending
                            }
                            placeholder={
                              oidcSettings?.hasClientSecret &&
                              !oidcClearSecretRequested
                                ? "••••••••••••"
                                : t("admin.clientSecretPlaceholder")
                            }
                            className="flex-1"
                          />
                          {oidcSettings?.hasClientSecret &&
                            !oidcSettings.isLocked && (
                              <Button
                                type="button"
                                variant="outline"
                                size="sm"
                                onClick={() =>
                                  setOidcClearSecretRequested(true)
                                }
                                disabled={
                                  updateOidcSettingsMutation.isPending ||
                                  oidcClearSecretRequested
                                }
                              >
                                {t("admin.clearSecret")}
                              </Button>
                            )}
                        </div>
                        <p className="text-xs text-muted-foreground">
                          {t("admin.clientSecretHint")}
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center justify-between rounded-lg border p-4">
                      <div className="space-y-0.5">
                        <Label
                          htmlFor="oidc-disable-internal-auth"
                          className="text-sm font-medium"
                        >
                          {t("admin.oidcOnlyMode")}
                        </Label>
                        <p className="text-sm text-muted-foreground">
                          {t("admin.oidcOnlyModeDesc")}
                        </p>
                      </div>
                      <Switch
                        id="oidc-disable-internal-auth"
                        checked={oidcFormData?.disableInternalAuth ?? false}
                        onCheckedChange={(checked) => {
                          if (!oidcSettings.isLocked && oidcFormData) {
                            setOidcFormData({
                              ...oidcFormData,
                              disableInternalAuth: checked,
                            });
                          }
                        }}
                        disabled={
                          oidcSettings.isLocked ||
                          updateOidcSettingsMutation.isPending
                        }
                      />
                    </div>

                    <div className="rounded-lg border bg-muted/30 p-4">
                      <p className="text-sm font-medium mb-1">
                        {t("admin.callbackUrl")}
                      </p>
                      <code className="text-xs break-all rounded bg-background px-2 py-1 block">
                        {oidcSettings.callbackUrl}
                      </code>
                      <p className="text-xs text-muted-foreground mt-2">
                        {t("admin.callbackUrlHint")}
                      </p>
                    </div>
                  </>
                )}

                {oidcFormHasChanges && (
                  <div className="flex justify-end pt-2">
                    <Button
                      onClick={handleSaveOidcSettings}
                      disabled={
                        updateOidcSettingsMutation.isPending ||
                        !oidcFormData ||
                        (oidcFormData.enabled &&
                          (!oidcFormData.issuerUrl?.trim() ||
                            !oidcFormData.clientId?.trim()))
                      }
                    >
                      {updateOidcSettingsMutation.isPending ? (
                        <>
                          <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                          {t("admin.saving")}
                        </>
                      ) : (
                        t("admin.saveOidc")
                      )}
                    </Button>
                  </div>
                )}
              </>
            ) : null}
          </CardContent>
        </Card>

        {/* Pending Users */}
        {pendingUsers.length > 0 && (
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between gap-4">
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md border bg-muted/50">
                    <Clock className="h-5 w-5 text-muted-foreground" />
                  </div>
                  <div>
                    <CardTitle>{t("admin.pendingApprovals")}</CardTitle>
                    <CardDescription className="mt-1">
                      {t("admin.pendingApprovalsDesc")}
                    </CardDescription>
                  </div>
                </div>
                <Badge variant="outline" className="shrink-0 text-sm">
                  {pendingUsersLoading
                    ? "..."
                    : t("admin.pendingCount", { count: pendingUsers.length })}
                </Badge>
              </div>
            </CardHeader>
            <CardContent>
              {pendingUsersLoading ? (
                <div className="flex items-center justify-center py-8">
                  <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>{t("admin.name")}</TableHead>
                      <TableHead>{t("admin.email")}</TableHead>
                      <TableHead className="text-center">
                        {t("admin.auth")}
                      </TableHead>
                      <TableHead>{t("admin.registered")}</TableHead>
                      <TableHead className="text-right">
                        {t("admin.actions")}
                      </TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {pendingUsers.map((user) => (
                      <TableRow key={user.id}>
                        <TableCell className="font-medium">
                          {user.name}
                        </TableCell>
                        <TableCell className="font-medium">
                          {user.email}
                        </TableCell>
                        <TableCell className="text-center">
                          <Badge
                            variant={
                              user.authMethod === "oidc"
                                ? "secondary"
                                : "outline"
                            }
                            className="font-normal"
                          >
                            {user.authMethod === "oidc"
                              ? t("admin.oidcBadge")
                              : t("admin.localBadge")}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          {format(new Date(user.createdAt), "MMM d, yyyy")}
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex justify-end gap-2">
                            <Button
                              size="sm"
                              variant="default"
                              onClick={() =>
                                approveUserMutation.mutate(user.id)
                              }
                              disabled={approveUserMutation.isPending}
                            >
                              <CheckCircle className="h-4 w-4 mr-1" />
                              {t("admin.approve")}
                            </Button>
                            <Button
                              size="sm"
                              variant="destructive"
                              onClick={() => handleRejectUser(user)}
                              disabled={rejectUserMutation.isPending}
                            >
                              <XCircle className="h-4 w-4 mr-1" />
                              {t("admin.reject")}
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        )}

        {/* User Management */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md border bg-muted/50">
                  <Users className="h-5 w-5 text-muted-foreground" />
                </div>
                <div>
                  <CardTitle>{t("admin.users")}</CardTitle>
                  <CardDescription className="mt-1">
                    {t("admin.usersDesc")}
                  </CardDescription>
                </div>
              </div>
              <Button onClick={handleCreateUser} size="sm">
                <Plus className="h-4 w-4" />
                {t("admin.createUser")}
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            {usersLoading ? (
              <div className="flex items-center justify-center py-8">
                <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Email</TableHead>
                    <TableHead className="text-center">
                      {t("admin.role")}
                    </TableHead>
                    <TableHead className="text-center">
                      {t("admin.auth")}
                    </TableHead>
                    <TableHead className="text-center">
                      {t("admin.status")}
                    </TableHead>
                    <TableHead className="text-center">
                      {t("admin.notes")}
                    </TableHead>
                    <TableHead className="text-center">
                      {t("admin.tags")}
                    </TableHead>
                    <TableHead>{t("admin.created")}</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {usersData?.users.map((user) => (
                    <TableRow key={user.id}>
                      <TableCell className="font-medium">
                        {user.name || "—"}
                      </TableCell>
                      <TableCell className="font-medium">
                        {user.email}
                      </TableCell>
                      <TableCell className="text-center">
                        {user.isAdmin ? (
                          <Badge variant="default">
                            {t("admin.adminBadge")}
                          </Badge>
                        ) : (
                          <Badge variant="outline">
                            {t("admin.userBadge")}
                          </Badge>
                        )}
                      </TableCell>
                      <TableCell className="text-center">
                        <Badge
                          variant={
                            user.authMethod === "oidc" ? "secondary" : "outline"
                          }
                          className="font-normal"
                        >
                          {user.authMethod === "oidc"
                            ? t("admin.oidcBadge")
                            : t("admin.localBadge")}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-center">
                        {user.status === "pending" ? (
                          <Badge variant="secondary">
                            {t("admin.pending")}
                          </Badge>
                        ) : (
                          <Badge variant="outline">{t("admin.active")}</Badge>
                        )}
                      </TableCell>
                      <TableCell className="text-center">
                        {user._count?.notes || 0}
                      </TableCell>
                      <TableCell className="text-center">
                        {user._count?.tags || 0}
                      </TableCell>
                      <TableCell>
                        {format(new Date(user.createdAt), "MMM d, yyyy")}
                      </TableCell>
                      <TableCell className="text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="icon">
                              <MoreVertical className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuItem
                              onClick={() => handleEditUser(user)}
                            >
                              {t("admin.edit")}
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => handleResetPassword(user)}
                            >
                              {t("admin.resetPassword")}
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => handleDeleteUser(user)}
                              className="text-destructive"
                            >
                              {t("admin.delete")}
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>

        {/* Create/Edit User Dialog */}
        <Dialog open={userDialogOpen} onOpenChange={setUserDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>
                {isEditing ? t("admin.editUser") : t("admin.createUser")}
              </DialogTitle>
              <DialogDescription>
                {isEditing
                  ? t("admin.editUserDesc")
                  : t("admin.createUserDesc")}
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="name">{t("admin.name")}</Label>
                <Input
                  id="name"
                  type="text"
                  value={formData.name}
                  onChange={(e) =>
                    setFormData({ ...formData, name: e.target.value })
                  }
                  placeholder={t("admin.userNamePlaceholder")}
                  maxLength={100}
                  required
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="email">{t("admin.email")}</Label>
                <Input
                  id="email"
                  type="email"
                  value={formData.email}
                  onChange={(e) =>
                    setFormData({ ...formData, email: e.target.value })
                  }
                  placeholder={t("admin.emailPlaceholder")}
                />
              </div>
              {!isEditing && (
                <div className="space-y-2">
                  <Label htmlFor="password">{t("auth.password")}</Label>
                  <Input
                    id="password"
                    type="password"
                    value={formData.password}
                    onChange={(e) =>
                      setFormData({ ...formData, password: e.target.value })
                    }
                    placeholder={t("admin.passwordMinPlaceholder")}
                    minLength={8}
                  />
                </div>
              )}
              {isEditing && (
                <div className="flex items-center justify-between space-x-2 rounded-lg border p-4">
                  <div className="space-y-0.5">
                    <Label htmlFor="admin-role">{t("admin.adminLabel")}</Label>
                    <p className="text-sm text-muted-foreground">
                      {selectedUser?.id === currentUser?.id
                        ? t("admin.adminSelfDesc")
                        : t("admin.adminOtherDesc")}
                    </p>
                  </div>
                  <Switch
                    id="admin-role"
                    checked={formData.isAdmin ?? false}
                    onCheckedChange={(checked) =>
                      setFormData({ ...formData, isAdmin: checked })
                    }
                    disabled={selectedUser?.id === currentUser?.id}
                  />
                </div>
              )}
            </div>
            <DialogFooter>
              <Button
                variant="outline"
                onClick={() => {
                  setUserDialogOpen(false);
                  setFormData({ email: "", password: "", name: "" });
                  setIsEditing(false);
                  setSelectedUser(null);
                }}
              >
                {t("common.cancel")}
              </Button>
              <Button
                onClick={handleSubmitUser}
                disabled={
                  createUserMutation.isPending ||
                  updateUserMutation.isPending ||
                  !formData.name ||
                  !formData.email ||
                  (!isEditing && !formData.password)
                }
              >
                {isEditing ? t("admin.update") : t("admin.create")}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Reset Password Dialog */}
        <Dialog
          open={resetPasswordDialogOpen}
          onOpenChange={setResetPasswordDialogOpen}
        >
          <DialogContent>
            <DialogHeader>
              <DialogTitle>{t("admin.resetPasswordTitle")}</DialogTitle>
              <DialogDescription>
                {t("admin.resetPasswordDesc", {
                  email: selectedUser?.email ?? "",
                })}
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              {resetPasswordResult ? (
                <div className="space-y-2">
                  <Label>{t("admin.newPassword")}</Label>
                  <div className="flex gap-2">
                    <Input value={resetPasswordResult} readOnly />
                    <Button onClick={copyPassword} variant="outline">
                      {t("admin.copy")}
                    </Button>
                  </div>
                  <p className="text-sm text-muted-foreground">
                    {t("admin.resetPasswordShareHint")}
                  </p>
                </div>
              ) : (
                <p className="text-sm text-muted-foreground">
                  {t("admin.resetPasswordGenerateHint")}
                </p>
              )}
            </div>
            <DialogFooter>
              <Button
                variant="outline"
                onClick={() => {
                  setResetPasswordDialogOpen(false);
                  setResetPasswordResult(null);
                  setSelectedUser(null);
                }}
              >
                {resetPasswordResult ? t("common.close") : t("common.cancel")}
              </Button>
              {!resetPasswordResult && (
                <Button
                  onClick={handleResetPasswordSubmit}
                  disabled={resetPasswordMutation.isPending}
                >
                  {resetPasswordMutation.isPending
                    ? t("admin.resetting")
                    : t("admin.resetPassword")}
                </Button>
              )}
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Delete User Confirmation Dialog */}
        <Dialog
          open={deleteUserDialogOpen}
          onOpenChange={setDeleteUserDialogOpen}
        >
          <DialogContent className="sm:max-w-md">
            <DialogHeader>
              <DialogTitle className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-destructive/10 flex items-center justify-center">
                  <AlertTriangle className="h-5 w-5 text-destructive" />
                </div>
                {t("admin.deleteUserTitle")}
              </DialogTitle>
              <DialogDescription className="pt-2">
                {t("admin.deleteUserConfirmBefore")}{" "}
                <span className="font-semibold text-foreground">
                  {selectedUser?.email}
                </span>
                {t("admin.deleteUserConfirmAfter")}
              </DialogDescription>
            </DialogHeader>
            {selectedUser && (
              <div className="py-4 space-y-2">
                <div className="text-sm text-muted-foreground">
                  {t("admin.willPermanentlyDelete")}
                </div>
                <ul className="text-sm space-y-1 list-disc list-inside text-muted-foreground">
                  <li>{t("admin.userAccount")}</li>
                  <li>
                    {t("admin.notesCount", {
                      count: selectedUser._count?.notes || 0,
                    })}
                  </li>
                  <li>
                    {t("admin.tagsCount", {
                      count: selectedUser._count?.tags || 0,
                    })}
                  </li>
                </ul>
                {selectedUser.isAdmin && (
                  <div className="pt-2 text-sm text-amber-600 dark:text-amber-500 font-medium">
                    {t("admin.adminWarning")}
                  </div>
                )}
              </div>
            )}
            <DialogFooter className="gap-2">
              <Button
                variant="outline"
                onClick={() => {
                  setDeleteUserDialogOpen(false);
                  setSelectedUser(null);
                }}
                disabled={deleteUserMutation.isPending}
              >
                {t("common.cancel")}
              </Button>
              <Button
                variant="destructive"
                onClick={handleDeleteConfirm}
                disabled={deleteUserMutation.isPending}
              >
                {deleteUserMutation.isPending ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    {t("admin.deleting")}
                  </>
                ) : (
                  t("admin.deleteUser")
                )}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Reject User Confirmation Dialog */}
        <Dialog
          open={rejectUserDialogOpen}
          onOpenChange={setRejectUserDialogOpen}
        >
          <DialogContent className="sm:max-w-md">
            <DialogHeader>
              <DialogTitle className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-destructive/10 flex items-center justify-center">
                  <XCircle className="h-5 w-5 text-destructive" />
                </div>
                {t("admin.rejectUserTitle")}
              </DialogTitle>
              <DialogDescription className="pt-2">
                {t("admin.rejectConfirmBefore")}{" "}
                <span className="font-semibold text-foreground">
                  {selectedUser?.email}
                </span>
                {t("admin.rejectConfirmAfter")}
              </DialogDescription>
            </DialogHeader>
            <DialogFooter className="gap-2">
              <Button
                variant="outline"
                onClick={() => {
                  setRejectUserDialogOpen(false);
                  setSelectedUser(null);
                }}
                disabled={rejectUserMutation.isPending}
              >
                {t("common.cancel")}
              </Button>
              <Button
                variant="destructive"
                onClick={handleRejectConfirm}
                disabled={rejectUserMutation.isPending}
              >
                {rejectUserMutation.isPending ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    {t("admin.rejecting")}
                  </>
                ) : (
                  t("admin.rejectUser")
                )}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminGuard>
  );
}
