import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// How tightly the UI is packed. Chosen by the user in Settings → Appearance.
enum DisplayDensity {
  standard,
  compact;

  String get label => switch (this) {
    DisplayDensity.standard => 'Default',
    DisplayDensity.compact => 'Compact',
  };
}

/// Spacing and sizing tokens, resolved from the current [DisplayDensity].
///
/// Lives in the theme as a [ThemeExtension], read via `context.dims`.
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
    required this.buttonPadding,
    required this.searchBarHeight,
    required this.appBarExpandedHeight,
    required this.largeAppBarHeight,
    required this.editorPadding,
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

  /// Inner padding of filled and outlined buttons.
  final EdgeInsets buttonPadding;

  /// Height of the notes-list search field. Material fixes its own at 56.
  final double searchBarHeight;

  final double appBarExpandedHeight;

  /// Expanded height of a [LargeTitleAppBar].
  final double largeAppBarHeight;

  /// Gutters around note content in the editor.
  final EdgeInsets editorPadding;

  EdgeInsets get screenInsets => EdgeInsets.all(screenGutter);

  static const standard = AppDimensions(
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
    buttonPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    searchBarHeight: 48,
    appBarExpandedHeight: 80,
    largeAppBarHeight: 120,
    editorPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  );

  static const compact = AppDimensions(
    xxs: 2,
    xs: 6,
    sm: 10,
    md: 12,
    lg: 16,
    xl: 20,
    xxl: 24,
    noteCardPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
    noteCardTitleGap: 6,
    noteCardTagGap: 8,
    noteCardFooterGap: 10,
    screenGutter: 12,
    gridSpacing: 12,
    listItemSpacing: 12,
    settingsRowPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    sectionGap: 24,
    pagePadding: 16,
    drawerItemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    drawerTagPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    sheetHeaderPadding: EdgeInsets.fromLTRB(20, 16, 20, 18),
    buttonPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    searchBarHeight: 44,
    appBarExpandedHeight: 68,
    largeAppBarHeight: 104,
    editorPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
  );

  factory AppDimensions.of(DisplayDensity density) => switch (density) {
    DisplayDensity.standard => standard,
    DisplayDensity.compact => compact,
  };

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
    EdgeInsets? buttonPadding,
    double? searchBarHeight,
    double? appBarExpandedHeight,
    double? largeAppBarHeight,
    EdgeInsets? editorPadding,
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
      buttonPadding: buttonPadding ?? this.buttonPadding,
      searchBarHeight: searchBarHeight ?? this.searchBarHeight,
      appBarExpandedHeight: appBarExpandedHeight ?? this.appBarExpandedHeight,
      largeAppBarHeight: largeAppBarHeight ?? this.largeAppBarHeight,
      editorPadding: editorPadding ?? this.editorPadding,
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
      buttonPadding: EdgeInsets.lerp(buttonPadding, other.buttonPadding, t)!,
      searchBarHeight: lerpDouble(searchBarHeight, other.searchBarHeight, t)!,
      appBarExpandedHeight: lerpDouble(
        appBarExpandedHeight,
        other.appBarExpandedHeight,
        t,
      )!,
      largeAppBarHeight: lerpDouble(
        largeAppBarHeight,
        other.largeAppBarHeight,
        t,
      )!,
      editorPadding: EdgeInsets.lerp(editorPadding, other.editorPadding, t)!,
    );
  }
}
