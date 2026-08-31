import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/dashboard/cubit/todo_cubit.dart';
import 'package:callx_ai/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:callx_ai/features/dashboard/domain/repositories/dashboard_repository.dart';


class _FakeTodoRepository implements DashboardRepository {
  final List<TodoItemModel> _todos = [];

  @override
  Future<DashboardSnapshot> getSnapshot() => throw UnimplementedError();

  @override
  Future<List<TodoItemModel>> getTodos() async => List.from(_todos);

  @override
  Future<TodoItemModel> createTodo(String text) async {
    final item = TodoItemModel(
      id: '${_todos.length + 1}',
      text: text,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    _todos.insert(0, item);
    return item;
  }

  @override
  Future<TodoItemModel> updateTodo(String id,
      {bool? isCompleted, String? text}) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) throw Exception('Not found');
    final updated = _todos[index].copyWith(
      isCompleted: isCompleted,
      text: text,
    );
    _todos[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
  }
}

void main() {
  late _FakeTodoRepository repository;
  late TodoCubit cubit;

  setUp(() {
    repository = _FakeTodoRepository();
    cubit = TodoCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('loads empty todos initially', () async {
    await cubit.loadTodos();
    expect(cubit.state.status, TodoStatus.loaded);
    expect(cubit.state.todos, isEmpty);
  });

  test('addTodo creates item and updates state', () async {
    await cubit.addTodo('Call customer Alex');
    expect(cubit.state.todos.length, 1);
    expect(cubit.state.todos.first.text, 'Call customer Alex');
    expect(cubit.state.todos.first.isCompleted, isFalse);
  });

  test('toggleTodo updates completed state', () async {
    await cubit.addTodo('Review metrics');
    final id = cubit.state.todos.first.id;

    await cubit.toggleTodo(id);
    expect(cubit.state.todos.first.isCompleted, isTrue);

    await cubit.toggleTodo(id);
    expect(cubit.state.todos.first.isCompleted, isFalse);
  });

  test('deleteTodo removes item from state', () async {
    await cubit.addTodo('Temporary note');
    final id = cubit.state.todos.first.id;

    await cubit.deleteTodo(id);
    expect(cubit.state.todos, isEmpty);
  });
}
