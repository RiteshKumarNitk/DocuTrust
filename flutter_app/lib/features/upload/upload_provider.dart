import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

class UploadState {
  final bool isLoading;
  final String? error;

  const UploadState({this.isLoading = false, this.error});

  UploadState copyWith({bool? isLoading, String? error}) {
    return UploadState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier(this._client) : super(const UploadState());

  final ApiClient _client;

  Future<String?> upload(String filePath, String docType) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final docId = await _client.uploadDocument(filePath, docType);
      return docId;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final uploadProvider = StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  return UploadNotifier(ApiClient());
});
