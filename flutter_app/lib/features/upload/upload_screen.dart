import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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
  Uint8List? _selectedBytes;
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
            _UploadZone(
              selectedFile: _selectedFile,
              selectedBytes: _selectedBytes,
              isLoading: state.isLoading,
            ),
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

    final bytes = await image.readAsBytes();

    setState(() {
      _selectedFile = image;
      _selectedBytes = bytes;
    });

    final docId = await ref.read(uploadProvider.notifier).upload(
          file: image,
          docType: _selectedType,
          bytes: bytes,
        );

    if (docId != null && context.mounted) {
      Navigator.pushNamed(context, '/result', arguments: docId);
    }
  }
}


class _UploadZone extends StatelessWidget {
  final XFile? selectedFile;
  final Uint8List? selectedBytes;
  final bool isLoading;

  const _UploadZone({this.selectedFile, this.selectedBytes, required this.isLoading});

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
                if (selectedBytes != null)
                  Image.memory(
                    selectedBytes!,
                    height: 150,
                    fit: BoxFit.contain,
                  )
                else
                  const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
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
