class ScenarioModel {
  final String id;
  String name;
  String category;
  String openingGreeting;
  String pitchSummary;
  List<String> qualifyingQuestions;
  String actionOnInterest;

  ScenarioModel({
    required this.id,
    required this.name,
    required this.category,
    required this.openingGreeting,
    required this.pitchSummary,
    required this.qualifyingQuestions,
    required this.actionOnInterest,
  });

  ScenarioModel copyWith({
    String? id,
    String? name,
    String? category,
    String? openingGreeting,
    String? pitchSummary,
    List<String>? qualifyingQuestions,
    String? actionOnInterest,
  }) {
    return ScenarioModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      openingGreeting: openingGreeting ?? this.openingGreeting,
      pitchSummary: pitchSummary ?? this.pitchSummary,
      qualifyingQuestions:
          qualifyingQuestions ?? List.from(this.qualifyingQuestions),
      actionOnInterest: actionOnInterest ?? this.actionOnInterest,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'openingGreeting': openingGreeting,
        'pitchSummary': pitchSummary,
        'qualifyingQuestions': qualifyingQuestions,
        'actionOnInterest': actionOnInterest,
      };

  factory ScenarioModel.fromJson(Map<String, dynamic> json) => ScenarioModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        category: json['category'] ?? 'Sales',
        openingGreeting: json['openingGreeting'] ?? '',
        pitchSummary: json['pitchSummary'] ?? '',
        qualifyingQuestions:
            List<String>.from(json['qualifyingQuestions'] ?? []),
        actionOnInterest: json['actionOnInterest'] ??
            'Send Follow-up Email & Tag as Hot Lead',
      );
}
