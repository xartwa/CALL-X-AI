class TodoItemModel {
  final String id;
  final String text;
  final bool isCompleted;
  final DateTime createdAt;

  const TodoItemModel({
    required this.id,
    required this.text,
    this.isCompleted = false,
    required this.createdAt,
  });

  TodoItemModel copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TodoItemModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TodoItemModel.fromJson(Map<String, dynamic> json) {
    return TodoItemModel(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
