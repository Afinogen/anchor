import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Spacing and sizing tokens.
///
/// Lives in the theme as a [ThemeExtension] so widgets read the values
/// via `context.dims` without watching any provider.
@immutable
class AppDimensions extends ThemeExtension<AppDimensions> {
  const AppDimensions({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.noteCardPadding,
    required this.noteCardTitleGap,
    required this.noteCardTagGap,
    required this.noteCardFooterGap,
    required this.screenGutter,
    required this.gridSpacing,
    required this.listItemSpacing,
    required this.settingsRowPadding,
    required this.sectionGap,
    required this.pagePadding,
    required this.drawerItemPadding,
    required this.drawerTagPadding,
    required this.sheetHeaderPadding,
    required this.appBarExpandedHeight,
    required this.largeAppBarExpandedHeight,
    required this.editorPadding,
    required this.notePreviewMaxLines,
    required this.noteCardSingleImageAspect,
  });

  // Generic spacing scale.
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  // Component tokens.
  final EdgeInsets noteCardPadding;
  final double noteCardTitleGap;
  final double noteCardTagGap;
  final double noteCardFooterGap;
  final double screenGutter;
  final double gridSpacing;
  final double listItemSpacing;
  final EdgeInsets settingsRowPadding;

  /// Vertical gap between page sections (settings groups).
  final double sectionGap;

  /// Edge padding of non-list content pages (settings).
  final double pagePadding;

  final EdgeInsets drawerItemPadding;
  final EdgeInsets drawerTagPadding;
  final EdgeInsets sheetHeaderPadding;
  final double appBarExpandedHeight;
  final double largeAppBarExpandedHeight;

  /// Gutters around note content in the editor.
  final EdgeInsets editorPadding;

  final int notePreviewMaxLines;
  final double noteCardSingleImageAspect;

  EdgeInsets get screenInsets => EdgeInsets.all(screenGutter);

  static const comfortable = AppDimensions(
    xxs: 4,
    xs: 8,
    sm: 12,
    md: 16,
    lg: 20,
    xl: 24,
    xxl: 32,
    noteCardPadding: EdgeInsets.fromLTRB(20, 16, 20, 16),
    noteCardTitleGap: 10,
    noteCardTagGap: 12,
    noteCardFooterGap: 14,
    screenGutter: 16,
    gridSpacing: 16,
    listItemSpacing: 16,
    settingsRowPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    sectionGap: 32,
    pagePadding: 20,
    drawerItemPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    drawerTagPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    sheetHeaderPadding: EdgeInsets.fromLTRB(24, 20, 24, 24),
    appBarExpandedHeight: 80,
    largeAppBarExpandedHeight: 120,
    editorPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    notePreviewMaxLines: 6,
    noteCardSingleImageAspect: 16 / 9,
  );

  @override
  AppDimensions copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    EdgeInsets? noteCardPadding,
    double? noteCardTitleGap,
    double? noteCardTagGap,
    double? noteCardFooterGap,
    double? screenGutter,
    double? gridSpacing,
    double? listItemSpacing,
    EdgeInsets? settingsRowPadding,
    double? sectionGap,
    double? pagePadding,
    EdgeInsets? drawerItemPadding,
    EdgeInsets? drawerTagPadding,
    EdgeInsets? sheetHeaderPadding,
    double? appBarExpandedHeight,
    double? largeAppBarExpandedHeight,
    EdgeInsets? editorPadding,
    int? notePreviewMaxLines,
    double? noteCardSingleImageAspect,
  }) {
    return AppDimensions(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      noteCardPadding: noteCardPadding ?? this.noteCardPadding,
      noteCardTitleGap: noteCardTitleGap ?? this.noteCardTitleGap,
      noteCardTagGap: noteCardTagGap ?? this.noteCardTagGap,
      noteCardFooterGap: noteCardFooterGap ?? this.noteCardFooterGap,
      screenGutter: screenGutter ?? this.screenGutter,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      listItemSpacing: listItemSpacing ?? this.listItemSpacing,
      settingsRowPadding: settingsRowPadding ?? this.settingsRowPadding,
      sectionGap: sectionGap ?? this.sectionGap,
      pagePadding: pagePadding ?? this.pagePadding,
      drawerItemPadding: drawerItemPadding ?? this.drawerItemPadding,
      drawerTagPadding: drawerTagPadding ?? this.drawerTagPadding,
      sheetHeaderPadding: sheetHeaderPadding ?? this.sheetHeaderPadding,
      appBarExpandedHeight: appBarExpandedHeight ?? this.appBarExpandedHeight,
      largeAppBarExpandedHeight:
          largeAppBarExpandedHeight ?? this.largeAppBarExpandedHeight,
      editorPadding: editorPadding ?? this.editorPadding,
      notePreviewMaxLines: notePreviewMaxLines ?? this.notePreviewMaxLines,
      noteCardSingleImageAspect:
          noteCardSingleImageAspect ?? this.noteCardSingleImageAspect,
    );
  }

  @override
  AppDimensions lerp(AppDimensions? other, double t) {
    if (other is! AppDimensions) return this;
    return AppDimensions(
      xxs: lerpDouble(xxs, other.xxs, t)!,
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      noteCardPadding: EdgeInsets.lerp(
        noteCardPadding,
        other.noteCardPadding,
        t,
      )!,
      noteCardTitleGap: lerpDouble(
        noteCardTitleGap,
        other.noteCardTitleGap,
        t,
      )!,
      noteCardTagGap: lerpDouble(noteCardTagGap, other.noteCardTagGap, t)!,
      noteCardFooterGap: lerpDouble(
        noteCardFooterGap,
        other.noteCardFooterGap,
        t,
      )!,
      screenGutter: lerpDouble(screenGutter, other.screenGutter, t)!,
      gridSpacing: lerpDouble(gridSpacing, other.gridSpacing, t)!,
      listItemSpacing: lerpDouble(listItemSpacing, other.listItemSpacing, t)!,
      settingsRowPadding: EdgeInsets.lerp(
        settingsRowPadding,
        other.settingsRowPadding,
        t,
      )!,
      sectionGap: lerpDouble(sectionGap, other.sectionGap, t)!,
      pagePadding: lerpDouble(pagePadding, other.pagePadding, t)!,
      drawerItemPadding: EdgeInsets.lerp(
        drawerItemPadding,
        other.drawerItemPadding,
        t,
      )!,
      drawerTagPadding: EdgeInsets.lerp(
        drawerTagPadding,
        other.drawerTagPadding,
        t,
      )!,
      sheetHeaderPadding: EdgeInsets.lerp(
        sheetHeaderPadding,
        other.sheetHeaderPadding,
        t,
      )!,
      appBarExpandedHeight: lerpDouble(
        appBarExpandedHeight,
        other.appBarExpandedHeight,
        t,
      )!,
      largeAppBarExpandedHeight: lerpDouble(
        largeAppBarExpandedHeight,
        other.largeAppBarExpandedHeight,
        t,
      )!,
      editorPadding: EdgeInsets.lerp(editorPadding, other.editorPadding, t)!,
      notePreviewMaxLines: t < 0.5
          ? notePreviewMaxLines
          : other.notePreviewMaxLines,
      noteCardSingleImageAspect: lerpDouble(
        noteCardSingleImageAspect,
        other.noteCardSingleImageAspect,
        t,
      )!,
    );
  }
}
