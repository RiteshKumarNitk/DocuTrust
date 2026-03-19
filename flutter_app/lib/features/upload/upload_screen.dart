import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'upload_provider.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _picker = ImagePicker();
  XFile? _selectedFile;
  String _selectedType = 'PAN';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Document')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: ['PAN', 'AADHAAR', 'SALARY_SLIP', 'BANK_STATEMENT']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type.replaceAll('_', ' '))))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Document type'),
            ),
            const SizedBox(height: 24),
            _UploadZone(selectedFile: _selectedFile, isLoading: state.isLoading),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: state.isLoading ? null : () => _pickAndUpload(context, ref),
              child: state.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Choose Document & Upload'),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 16),
              Text(state.error!, style: TextStyle(color: Colors.red[700])),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _selectedFile = image);
    final docId = await ref.read(uploadProvider.notifier).upload(image.path, _selectedType);
    if (docId != null && context.mounted) {
      Navigator.pushNamed(context, '/result', arguments: docId);
    }
  }
}

class _UploadZone extends StatelessWidget {
  final XFile? selectedFile;
  final bool isLoading;

  const _UploadZone({this.selectedFile, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (selectedFile != null)
            Column(
              children: [
                Image.file(
                  File(selectedFile!.path),
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Text(selectedFile!.name, style: const TextStyle(fontSize: 12)),
              ],
            )
          else ...[
            Icon(Icons.cloud_upload, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 12),
            const Text('Upload an image or PDF of your document'),
          ],
          if (isLoading) ...[
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
