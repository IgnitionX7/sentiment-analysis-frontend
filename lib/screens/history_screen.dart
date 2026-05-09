import 'package:flutter/material.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppEmptyState(
        icon: Icons.history_rounded,
        title: 'No History Yet',
        subtitle: 'Your past analyses will appear here.',
      ),
    );
  }
}
