import 'package:flutter/material.dart';
import 'package:callx_ai/core/models/tag_model.dart';

class WorkspaceConfigurationModel {
  final List<TagModel> pipelineStages;
  final List<TagModel> customTags;
  final List<Color> tagColors;
  final List<String> tagColorHexes;

  const WorkspaceConfigurationModel({
    this.pipelineStages = const [],
    this.customTags = const [],
    this.tagColors = const [],
    this.tagColorHexes = const [],
  });

  factory WorkspaceConfigurationModel.fromJson(Map<String, dynamic> json) {
    // Pipeline stages
    final rawStages = json['pipelineStages'] ?? json['pipeline_stages'] ?? [];
    final stagesList = (rawStages is List ? rawStages : [])
        .map((e) => e is Map<String, dynamic>
            ? TagModel.fromJson(e)
            : TagModel(
                id: e.toString(),
                label: e.toString(),
                color: const Color(0xFF3B82F6)))
        .toList();

    // Custom tags
    final rawTags = json['customTags'] ?? json['custom_tags'] ?? [];
    final tagsList = (rawTags is List ? rawTags : [])
        .map((e) => e is Map<String, dynamic>
            ? TagModel.fromJson(e)
            : TagModel(
                id: e.toString(),
                label: e.toString(),
                color: const Color(0xFF3B82F6)))
        .toList();

    // Tag colors
    final rawColors = json['tagColors'] ?? json['tag_colors'] ?? [];
    final hexStrings = <String>[];
    final colorsList = <Color>[];

    if (rawColors is List) {
      for (final item in rawColors) {
        if (item is String) {
          hexStrings.add(item);
          colorsList.add(TagModel.hexToColor(item));
        } else if (item is int) {
          colorsList.add(Color(item));
          hexStrings.add(
              '#${(item & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}');
        }
      }
    }

    return WorkspaceConfigurationModel(
      pipelineStages: List.unmodifiable(stagesList),
      customTags: List.unmodifiable(tagsList),
      tagColors: List.unmodifiable(colorsList),
      tagColorHexes: List.unmodifiable(hexStrings),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pipelineStages': pipelineStages.map((e) => e.toJson()).toList(),
      'customTags': customTags.map((e) => e.toJson()).toList(),
      'tagColors': tagColorHexes,
    };
  }
}
