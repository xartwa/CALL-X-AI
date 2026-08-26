import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_snapshot_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<DashboardSnapshot> getSnapshot() async {
    try {
      final json = await _remoteDataSource.getSnapshot();
      return DashboardSnapshotModel.fromJson(json).entity;
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
}
