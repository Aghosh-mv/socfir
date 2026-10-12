import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Your Account Reach (Last 7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(context, 40, 'M'),
                  _buildBar(context, 80, 'T'),
                  _buildBar(context, 60, 'W'),
                  _buildBar(context, 120, 'T', highlight: true),
                  _buildBar(context, 90, 'F'),
                  _buildBar(context, 150, 'S'),
                  _buildBar(context, 110, 'S'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Profile Views', '4,203', '+12%'),
                _buildStat('Impressions', '15.2k', '+5%'),
                _buildStat('Engagements', '1,490', '-2%'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, double height, String label, {bool highlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: highlight ? AppColors.accent : AppColors.accent.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStat(String title, String value, String trend) {
    final isUp = trend.startsWith('+');
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(trend, style: TextStyle(color: isUp ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
