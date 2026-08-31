import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../models/todo_item_model.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_snapshot_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  Future<T> _request<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        throw const AppException(AppErrorType.unauthorized);
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw const AppException(AppErrorType.timeout);
      }
      if (error.type == DioExceptionType.connectionError ||
          (error.type == DioExceptionType.unknown && error.response == null)) {
        throw const AppException(AppErrorType.network);
      }
      throw AppException.fromDio(error);
    } on FormatException {
      throw const AppException(AppErrorType.invalidData);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(AppErrorType.unknown);
    }
  }

  @override
  Future<DashboardSnapshot> getSnapshot() => _request(() async {
        final json = await _remoteDataSource.getSnapshot();
        return DashboardSnapshotModel.fromJson(json).entity;
      });

  @override
  Future<List<TodoItemModel>> getTodos() => _request(() async {
        final raw = await _remoteDataSource.getTodos();
        return raw.map(TodoItemModel.fromJson).toList();
      });

  @override
  Future<TodoItemModel> createTodo(String text) => _request(() async {
        final raw = await _remoteDataSource.createTodo(text);
        return TodoItemModel.fromJson(raw);
      });

  @override
  Future<TodoItemModel> updateTodo(String id,
          {bool? isCompleted, String? text}) =>
      _request(() async {
        final raw = await _remoteDataSource.updateTodo(id,
            isCompleted: isCompleted, text: text);
        return TodoItemModel.fromJson(raw);
      });

  @override
  Future<void> deleteTodo(String id) =>
      _request(() => _remoteDataSource.deleteTodo(id));
}

