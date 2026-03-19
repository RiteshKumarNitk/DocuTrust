import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/models/document_model.dart';

final documentProvider = StateNotifierProvider.family<DocumentNotifier, DocumentModel?, String>((ref, documentId) {
  return DocumentNotifier(ApiClient(), documentId);
});

class DocumentNotifier extends StateNotifier<DocumentModel?> {
  DocumentNotifier(this._api, this.documentId) : super(null);

  final ApiClient _api;
  final String documentId;

  Future<void> fetch() async {
    try {
      final data = await _api.getDocumentResult(documentId);
      state = DocumentModel.fromJson(data);
    } catch (_) {
      // ignore
    }
  }
}
