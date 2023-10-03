
class ReportRequstDTO {
  final String content;
  final String carpoolId;
  final String reportedUser;
  final String reporter;
  final String reportType;
  final String reportDate;

  ReportRequstDTO({
    required this.content,
    required this.carpoolId,
    required this.reportedUser,
    required this.reporter,
    required this.reportType,
    required this.reportDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'carpoolId': carpoolId,
      'reportedUser': reportedUser,
      'reporter': reporter,
      'reportType': reportType,
      'reportDate': reportDate,
    };
  }
}
