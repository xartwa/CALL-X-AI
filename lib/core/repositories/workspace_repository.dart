import 'package:callx_ai/core/models/tag_model.dart';
import 'package:callx_ai/core/models/workspace_configuration_model.dart';

abstract class WorkspaceRepository {
  Future<WorkspaceConfigurationModel> getWorkspaceConfiguration({Object? cancelToken});
  Future<WorkspaceConfigurationModel> updateWorkspaceConfiguration(
    List<TagModel> customTags, {
    Object? cancelToken,
  });
}
