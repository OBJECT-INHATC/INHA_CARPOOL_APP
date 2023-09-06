import 'enums/ReportType.enum';

class ReportRequstDTO {
  final String content;
  final String carpoolId;
  final String userName;
  final String reporter;
  final String reportType;
  final String reportDate;

  ReportRequstDTO({
    required this.content,
    required this.carpoolId,
    required this.userName,
    required this.reporter,
    required this.reportType,
    required this.reportDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'carpoolId': carpoolId,
      'userName': userName,
      'reporter': reporter,
      'reportType': reportType,
      'reportDate': reportDate,
    };
  }
}
