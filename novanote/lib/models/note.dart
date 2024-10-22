class Note {
  int? id;
  String title;
  String content;
  int categoryId;
  bool isImportant;
  bool isFavorite;
  bool isArchived;
  bool isLocked;
  String? password;
  DateTime createdAt;
  DateTime modifiedAt;
  List<String> attachments;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    this.isImportant = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.isLocked = false,
    this.password,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? attachments,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.modifiedAt = modifiedAt ?? DateTime.now(),
        this.attachments = attachments ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'is_important': isImportant ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'is_locked': isLocked ? 1 : 0,
      'password': password,
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt.toIso8601String(),
      'attachments': attachments.join(','),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      categoryId: map['category_id'],
      isImportant: map['is_important'] == 1,
      isFavorite: map['is_favorite'] == 1,
      isArchived: map['is_archived'] == 1,
      isLocked: map['is_locked'] == 1,
      password: map['password'],
      createdAt: DateTime.parse(map['created_at']),
      modifiedAt: DateTime.parse(map['modified_at']),
      attachments: map['attachments'].toString().split(','),
    );
  }
}
