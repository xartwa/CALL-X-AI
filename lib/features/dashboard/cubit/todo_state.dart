import '../models/todo_item_model.dart';

enum TodoStatus { initial, loading, loaded, error }

class TodoState {
  final List<TodoItemModel> todos;
  final TodoStatus status;
  final String? errorMessage;

  const TodoState({
    this.todos = const [],
    this.status = TodoStatus.initial,
    this.errorMessage,
  });

  int get totalCount => todos.length;
  int get completedCount => todos.where((t) => t.isCompleted).length;
  int get pendingCount => todos.where((t) => !t.isCompleted).length;
  double get completionPercentage =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount);

  TodoState copyWith({
    List<TodoItemModel>? todos,
    TodoStatus? status,
    String? errorMessage,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
