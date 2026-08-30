// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_revision.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NoteRevisionAuthor _$NoteRevisionAuthorFromJson(Map<String, dynamic> json) =>
    _NoteRevisionAuthor(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImage: json['profileImage'] as String?,
    );

Map<String, dynamic> _$NoteRevisionAuthorToJson(_NoteRevisionAuthor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'profileImage': instance.profileImage,
    };

_NoteRevision _$NoteRevisionFromJson(Map<String, dynamic> json) =>
    _NoteRevision(
      id: json['id'] as String,
      noteId: json['noteId'] as String,
      version: (json['version'] as num).toInt(),
      title: json['title'] as String,
      cause: $enumDecode(
        _$RevisionCauseEnumMap,
        json['cause'],
        unknownValue: RevisionCause.edit,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      author: json['author'] == null
          ? null
          : NoteRevisionAuthor.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String?,
    );

Map<String, dynamic> _$NoteRevisionToJson(_NoteRevision instance) =>
    <String, dynamic>{
      'id': instance.id,
      'noteId': instance.noteId,
      'version': instance.version,
      'title': instance.title,
      'cause': _$RevisionCauseEnumMap[instance.cause]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'author': instance.author,
      'content': instance.content,
    };

const _$RevisionCauseEnumMap = {
  RevisionCause.edit: 'edit',
  RevisionCause.conflict: 'conflict',
  RevisionCause.restore: 'restore',
};

_NoteRevisionPage _$NoteRevisionPageFromJson(Map<String, dynamic> json) =>
    _NoteRevisionPage(
      revisions:
          (json['revisions'] as List<dynamic>?)
              ?.map((e) => NoteRevision.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <NoteRevision>[],
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$NoteRevisionPageToJson(_NoteRevisionPage instance) =>
    <String, dynamic>{
      'revisions': instance.revisions,
      'nextCursor': instance.nextCursor,
    };
