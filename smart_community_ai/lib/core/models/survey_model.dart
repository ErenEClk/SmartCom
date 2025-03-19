class SurveyModel {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String createdBy;
  final bool isActive;
  final List<SurveyQuestion> questions;
  final bool hasVoted;

  SurveyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    required this.isActive,
    required this.questions,
    required this.hasVoted,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      createdBy: json['createdBy'] ?? '',
      isActive: json['isActive'] ?? false,
      questions: json['questions'] != null
          ? List<SurveyQuestion>.from(
              json['questions'].map((x) => SurveyQuestion.fromJson(x)))
          : [],
      hasVoted: json['hasVoted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'createdBy': createdBy,
      'isActive': isActive,
      'questions': questions.map((x) => x.toJson()).toList(),
      'hasVoted': hasVoted,
    };
  }
}

class SurveyQuestion {
  final String id;
  final String question;
  final String type; // multiple_choice, single_choice, text
  final List<SurveyOption>? options;
  final String? userAnswer; // Kullanıcının cevabı (text için)
  final List<String>? userAnswers; // Kullanıcının cevapları (multiple_choice için)

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.userAnswer,
    this.userAnswers,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      type: json['type'] ?? '',
      options: json['options'] != null
          ? List<SurveyOption>.from(
              json['options'].map((x) => SurveyOption.fromJson(x)))
          : null,
      userAnswer: json['userAnswer'],
      userAnswers: json['userAnswers'] != null
          ? List<String>.from(json['userAnswers'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options?.map((x) => x.toJson()).toList(),
      'userAnswer': userAnswer,
      'userAnswers': userAnswers,
    };
  }
}

class SurveyOption {
  final String id;
  final String text;
  final int votes;
  final double percentage;

  SurveyOption({
    required this.id,
    required this.text,
    required this.votes,
    required this.percentage,
  });

  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    return SurveyOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      votes: json['votes'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
      'percentage': percentage,
    };
  }
} 