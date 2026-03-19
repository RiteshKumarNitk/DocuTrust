import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final int score;
  final bool approved;

  const ScoreCard({super.key, required this.score, required this.approved});

  @override
  Widget build(BuildContext context) {
    final color = approved ? Colors.green[700]! : Colors.red[700]!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              approved ? 'APPROVED' : 'REJECTED',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    color: color,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Score out of 100 (threshold: 70)',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
