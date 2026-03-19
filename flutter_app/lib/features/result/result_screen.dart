import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/models/document_model.dart';
import '../../shared/widgets/score_card.dart';

class ResultScreen extends StatefulWidget {
  final String documentId;
  const ResultScreen({super.key, required this.documentId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  DocumentModel? _doc;
  Timer? _pollTimer;
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _fetchResult();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (_doc?.isProcessing ?? true) _fetchResult();
      },
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchResult() async {
    try {
      final data = await _api.getDocumentResult(widget.documentId);
      setState(() => _doc = DocumentModel.fromJson(data));
      if (!(_doc?.isProcessing ?? true)) _pollTimer?.cancel();
    } catch (_) {
      // silently retry on network error — polling will retry
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Result')),
      body: _doc == null || _doc!.isProcessing
          ? const _ProcessingView()
          : _ResultView(doc: _doc!),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analysing your document…'),
            Text(
              'This usually takes 5–10 seconds.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
}

class _ResultView extends StatelessWidget {
  final DocumentModel doc;
  const _ResultView({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ScoreCard(score: doc.score ?? 0, approved: doc.isApproved),
          const SizedBox(height: 24),
          if (doc.extracted != null) _ExtractedFields(data: doc.extracted!),
          if (doc.errorMsg != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(doc.errorMsg!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExtractedFields extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ExtractedFields({required this.data});

  @override
  Widget build(BuildContext context) {
    final pan = data['pan'] as String?;
    final name = data['name'] as String?;
    final income = data['income'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Extracted data', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (pan != null) _Row(label: 'PAN', value: pan),
            if (name != null) _Row(label: 'Name', value: name),
            if (income != null) _Row(label: 'Income', value: _formatIncome(income)),
          ],
        ),
      ),
    );
  }

  static String _formatIncome(dynamic income) {
    final numValue = income is num ? income : int.tryParse(income.toString()) ?? 0;

    // Format as Indian rupees with comma grouping (e.g. 1,23,456)
    final digits = numValue.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      }
    }
    return '₹${buffer.toString().split('').reversed.join()}';
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
