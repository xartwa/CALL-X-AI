import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../models/todo_item_model.dart';
import 'todo_state.dart';

export 'todo_state.dart';
export '../models/todo_item_model.dart';

class TodoCubit extends Cubit<TodoState> {
  final DashboardRepository _repository;

  TodoCubit(this._repository) : super(const TodoState()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      emit(state.copyWith(status: TodoStatus.loading));
      final todos = await _repository.getTodos();
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

    try {
      final newItem = await _repository.createTodo(trimmed);
      final updatedTodos = [newItem, ...state.todos];
      emit(state.copyWith(todos: updatedTodos));
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> toggleTodo(String id) async {
    final target = state.todos.firstWhere(
      (t) => t.id == id,
      orElse: () => TodoItemModel(
        id: id,
        text: '',
        createdAt: DateTime.now(),
      ),
    );
    if (target.text.isEmpty) return;

    final newStatus = !target.isCompleted;
    // Optimistic update
    final optimisticList = state.todos.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: newStatus);
      }
      return todo;
    }).toList();
    emit(state.copyWith(todos: optimisticList));

    try {
      final updated = await _repository.updateTodo(id, isCompleted: newStatus);
      final finalTodos = state.todos.map((todo) {
        if (todo.id == id) return updated;
        return todo;
      }).toList();
      emit(state.copyWith(todos: finalTodos));
    } catch (_) {
      // Revert if error
      loadTodos();
    }
  }

  Future<void> deleteTodo(String id) async {
    final previousTodos = state.todos;
    final updatedTodos = state.todos.where((todo) => todo.id != id).toList();
    emit(state.copyWith(todos: updatedTodos));

    try {
      await _repository.deleteTodo(id);
    } catch (_) {
      emit(state.copyWith(todos: previousTodos));
    }
  }

  Future<void> clearCompleted() async {
    final completedItems =
        state.todos.where((todo) => todo.isCompleted).toList();
    final remainingTodos =
        state.todos.where((todo) => !todo.isCompleted).toList();
    emit(state.copyWith(todos: remainingTodos));

    for (final item in completedItems) {
      try {
        await _repository.deleteTodo(item.id);
      } catch (_) {}
    }
  }
}

