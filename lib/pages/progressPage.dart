// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services.dart/lists.dart';

class ProgressPage extends StatefulWidget {
  final List<Map<String, dynamic>> habits;
  
  const ProgressPage({Key? key, required this.habits}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  Widget build(BuildContext context) {
    final topHabits = _getTopHabits();
    final needsImprovement = _getNeedsImprovement();

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 252,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.purple[700]!,
                  Colors.deepPurple[800]!,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 20),
                    Text(
                      "Hey ${_getGreeting()}!",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMotivationalMessage(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    // const Spacer(),
                    _buildWeeklyOverview(),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    "Top Performing Habits",
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildHabitList(topHabits, isTopPerforming: true),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    "Needs Improvement",
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildHabitList(needsImprovement, isTopPerforming: false),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    final completionRate = _calculateWeeklyCompletionRate();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            margin: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: completionRate,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
                Center(
                  child: Text(
                    '${(completionRate * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getWeeklyStats(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitList(List<Map<String, dynamic>> habits, {required bool isTopPerforming}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final progress = _calculateHabitProgress(habit);
        
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTopPerforming ? Colors.green : Colors.orange,
                    ),
                    strokeWidth: 8,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getHabitStats(habit),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _getHabitIcon(habit),
                  color: isTopPerforming ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  String _getMotivationalMessage() {
    final completionRate = _calculateWeeklyCompletionRate();
    if (completionRate >= 0.8) return "You're crushing it! 🔥";
    if (completionRate >= 0.5) return "Keep up the good work! 💪";
    return "Small steps lead to big changes! 🌱";
  }

  double _calculateWeeklyCompletionRate() {
    if (widget.habits.isEmpty) return 0.0;
    final completedCount = widget.habits.where((h) => h['completed']).length;
    return completedCount / widget.habits.length;
  }

  String _getWeeklyStats() {
    final completedCount = widget.habits.where((h) => h['completed']).length;
    return '$completedCount/${widget.habits.length} habits completed this week';
  }

  List<Map<String, dynamic>> _getTopHabits() {
    final sortedHabits = [...widget.habits]..sort((a, b) => 
        (b['streak'] as int? ?? 0).compareTo(a['streak'] as int? ?? 0));
    return sortedHabits.take(3).toList();
  }

  List<Map<String, dynamic>> _getNeedsImprovement() {
    final sortedHabits = [...widget.habits]..sort((a, b) => 
        (a['streak'] as int? ?? 0).compareTo(b['streak'] as int? ?? 0));
    return sortedHabits.take(3).toList();
  }

  double _calculateHabitProgress(Map<String, dynamic> habit) {
    final streak = habit['streak'] as int? ?? 0;
    return streak / 7; // Progress relative to a week
  }

  String _getHabitStats(Map<String, dynamic> habit) {
    final streak = habit['streak'] as int? ?? 0;
    return '$streak day streak';
  }

  IconData _getHabitIcon(Map<String, dynamic> habit) {
    switch (habit['category']) {
      case 'Health':
        return Icons.favorite;
      case 'Learning':
        return Icons.school;
      case 'Work':
        return Icons.work;
      default:
        return Icons.star;
    }
  }
}
