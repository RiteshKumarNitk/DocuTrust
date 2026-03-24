import 'dart:convert';

enum DocStatus { pending, processing, done, failed }
enum DocResult { approved, rejected, unknown }

class DocumentModel {
  final String id;
  final DocStatus status;
  final int? score;
  final DocResult result;
  final Map<String, dynamic>? extracted;
  final String? errorMsg;

  const DocumentModel({
    required this.id,
    required this.status,
    this.score,
    this.result = DocResult.unknown,
    this.extracted,
    this.errorMsg,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      status: _parseStatus(json['status'] as String),
      score: json['score'] as int?,
      result: _parseResult(json['result'] as String?),
      extracted: json['extracted'] != null ? jsonDecode(json['extracted'] as String) : null,
      errorMsg: json['errorMsg'] as String?,
    );
  }

  static DocStatus _parseStatus(String s) => switch (s) {
        'PENDING' => DocStatus.pending,
        'PROCESSING' => DocStatus.processing,
        'DONE' => DocStatus.done,
        'FAILED' => DocStatus.failed,
        _ => DocStatus.pending,
      };

  static DocResult _parseResult(String? r) => switch (r) {
        'APPROVED' => DocResult.approved,
        'REJECTED' => DocResult.rejected,
        _ => DocResult.unknown,
      };

  bool get isProcessing => status == DocStatus.pending || status == DocStatus.processing;
  bool get isApproved => result == DocResult.approved;
}
