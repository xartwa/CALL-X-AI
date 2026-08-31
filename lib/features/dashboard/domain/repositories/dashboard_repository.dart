import '../entities/dashboard_snapshot.dart';
import '../../models/todo_item_model.dart';

abstract interface class DashboardRepository {
  Future<DashboardSnapshot> getSnapshot();
  Future<List<TodoItemModel>> getTodos();
  Future<TodoItemModel> createTodo(String text);
  Future<TodoItemModel> updateTodo(String id, {bool? isCompleted, String? text});
  Future<void> deleteTodo(String id);
}

