import 'package:dio/dio.dart';
import 'package:callx_ai/core/datasources/workspace_remote_data_source.dart';
import 'package:callx_ai/core/errors/app_exception.dart';
import 'package:callx_ai/core/models/tag_model.dart';
import 'package:callx_ai/core/models/workspace_configuration_model.dart';
import 'package:callx_ai/core/repositories/workspace_repository.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  const WorkspaceRepositoryImpl(this.remote);
  final WorkspaceRemoteDataSource remote;

  @override
  Future<WorkspaceConfigurationModel> getWorkspaceConfiguration({
    Object? cancelToken,
  }) async {
    try {
      final raw = await remote.getWorkspaceConfiguration(
        cancelToken: cancelToken as CancelToken?,
      );
      return WorkspaceConfigurationModel.fromJson(raw);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<WorkspaceConfigurationModel> updateWorkspaceConfiguration(
    List<TagModel> customTags, {
    Object? cancelToken,
  }) async {
    try {
      final body = {
        'customTags': customTags.map((tag) => tag.toApiJson()).toList(),
      };
      final raw = await remote.updateWorkspaceConfiguration(
        body,
        cancelToken: cancelToken as CancelToken?,
      );
      return WorkspaceConfigurationModel.fromJson(raw);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}
