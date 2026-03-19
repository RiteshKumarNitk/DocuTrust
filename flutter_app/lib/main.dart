import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/upload/upload_screen.dart';
import 'features/result/result_screen.dart';

void main() {
  runApp(const ProviderScope(child: DocuTrustApp()));
}

class DocuTrustApp extends StatelessWidget {
  const DocuTrustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocuTrust',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => const UploadScreen(),
        '/result': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final documentId = args is String ? args : null;
          if (documentId == null) {
            return const Scaffold(body: Center(child: Text('Missing document id')));
          }
          return ResultScreen(documentId: documentId);
        },
      },
    );
  }
}
