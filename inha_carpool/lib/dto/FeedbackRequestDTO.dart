class FeedbackRequestDTO {
  final String reporter;
  final String feedbackType;
  final String content;
  final String feedbackDate;

  FeedbackRequestDTO({
    required this.reporter,
    required this.feedbackType,
    required this.content,
    required this.feedbackDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'reporter': reporter,
      'feedbackType': feedbackType,
      'content': content,
      'feedbackDate': feedbackDate,
    };
  }
}