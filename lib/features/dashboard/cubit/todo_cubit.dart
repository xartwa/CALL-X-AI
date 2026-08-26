import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/preferences_service.dart';
import '../models/todo_item_model.dart';
import 'todo_state.dart';

export 'todo_state.dart';
export '../models/todo_item_model.dart';

class TodoCubit extends Cubit<TodoState> {
  final PreferencesService _preferencesService;

  TodoCubit(this._preferencesService) : super(const TodoState()) {
    loadTodos();
  }

  void loadTodos() {
    try {
      emit(state.copyWith(status: TodoStatus.loading));
      final rawList = _preferencesService.loadTodos();
      final todos = rawList.map((item) => TodoItemModel.fromJson(item)).toList();
      emit(state.copyWith(
        todos: todos,
        status: TodoStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addTodo(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final newItem = TodoItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final updatedTodos = [newItem, ...state.todos];
    emit(state.copyWith(todos: updatedTodos));
    await _saveToStorage(updatedTodos);
  }

  Future<void> toggleTodo(String id) async {
    final updatedTodos = state.todos.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();

    emit(state.copyWith(todos: updatedTodos));
    await _saveToStorage(updatedTodos);
  }

  Future<void> deleteTodo(String id) async {
    final updatedTodos = state.todos.where((todo) => todo.id != id).toList();
    emit(state.copyWith(todos: updatedTodos));
    await _saveToStorage(updatedTodos);
  }

  Future<void> clearCompleted() async {
    final updatedTodos = state.todos.where((todo) => !todo.isCompleted).toList();
    emit(state.copyWith(todos: updatedTodos));
    await _saveToStorage(updatedTodos);
  }

  Future<void> _saveToStorage(List<TodoItemModel> todos) async {
    try {
      final jsonList = todos.map((t) => t.toJson()).toList();
      await _preferencesService.saveTodos(jsonList);
    } catch (_) {
      // Storage error handling if needed
    }
  }
}
