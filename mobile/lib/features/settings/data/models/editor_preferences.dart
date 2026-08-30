/// Editor preferences model
class EditorPreferences {
  /// Whether to sort checklist items (checked to bottom, unchecked to top)
  final bool sortChecklistItems;

  /// Whether checked items are grouped under the day they were checked.
  final bool groupCheckedByDate;

  const EditorPreferences({
    this.sortChecklistItems = true,
    this.groupCheckedByDate = false,
  });

  EditorPreferences copyWith({
    bool? sortChecklistItems,
    bool? groupCheckedByDate,
  }) {
    return EditorPreferences(
      sortChecklistItems: sortChecklistItems ?? this.sortChecklistItems,
      groupCheckedByDate: groupCheckedByDate ?? this.groupCheckedByDate,
    );
  }
}
