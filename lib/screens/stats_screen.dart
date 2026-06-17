import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models.dart';
import '../services.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final results = HiveService.getResults();

    int totalCorrect = 0;
    int totalIncorrect = 0;

    for (var res in results) {
      totalCorrect += res.correctAnswers;
      totalIncorrect += (res.totalQuestions - res.correctAnswers);
    }

    final bool hasData = results.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Your Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.indigo.shade800],
          ),
        ),
        child: !hasData
            ? const Center(
                child: Text(
                  'No quizzes played yet.',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    _buildChartSection(totalCorrect, totalIncorrect),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Game History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final reversedIndex = results.length - 1 - index;
                          final res = results[reversedIndex];
                          return _buildResultCard(res);
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildChartSection(int correct, int incorrect) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Overall Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green.shade500,
                      value: correct.toDouble(),
                      title: 'Correct: $correct',
                      radius: 55,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.red.shade500,
                      value: incorrect.toDouble(),
                      title: 'Errors: $incorrect',
                      radius: 55,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(QuizResult res) {
    final double percent = res.totalQuestions > 0 ? (res.correctAnswers / res.totalQuestions) : 0;
    final color = percent >= 0.8 ? Colors.green.shade600 : (percent >= 0.5 ? Colors.orange.shade600 : Colors.red.shade600);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.assessment_rounded, color: color, size: 28),
        ),
        title: Text(
          'Score: ${res.correctAnswers} / ${res.totalQuestions}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          _formatDate(res.date),
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${(percent * 100).toInt()}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
