import 'dart:math';

import 'package:collection/collection.dart';

class AnalyticsService {
  static Map<String, dynamic> generateInsights(List<Map<String, dynamic>> habits) {
    return {
      'streakData': _calculateStreakData(habits),
      'categoryBreakdown': _getCategoryBreakdown(habits),
      'completionTrends': _getCompletionTrends(habits),
      'bestPerformingHabits': _getBestPerformingHabits(habits),
      'timeDistribution': _getTimeDistribution(habits),
    };
  }

  static Map<String, int> _calculateStreakData(List<Map<String, dynamic>> habits) {
    final streaks = habits.map((h) => h['streak'] as int? ?? 0);
    return {
      'currentStreak': streaks.fold(0, max),
      'averageStreak': streaks.isEmpty ? 0 : streaks.sum ~/ streaks.length,
      'totalCompletions': habits.where((h) => h['completed']).length,
    };
  }

  static Map<String, double> _getCategoryBreakdown(List<Map<String, dynamic>> habits) {
    final categories = groupBy(habits, (Map<String, dynamic> h) => h['category'] as String? ?? 'Other');
    final total = habits.length;
    
    return categories.map((key, value) => 
      MapEntry(key, value.length / total));
  }

  static List<Map<String, dynamic>> _getCompletionTrends(List<Map<String, dynamic>> habits) {
    // Last 7 days completion rate
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: index));
      final dayHabits = habits.where((h) {
        if (h['lastCompleted'] == null) return false;
        final completed = DateTime.parse(h['lastCompleted']);
        return completed.year == date.year && 
               completed.month == date.month && 
               completed.day == date.day;
      });
      
      return {
        'date': date,
        'completion': dayHabits.length / (habits.isEmpty ? 1 : habits.length),
      };
    }).reversed.toList();
  }

  static List<Map<String, dynamic>> _getBestPerformingHabits(List<Map<String, dynamic>> habits) {
    final sortedHabits = [...habits]..sort((a, b) => 
      (b['streak'] as int? ?? 0).compareTo(a['streak'] as int? ?? 0));
    return sortedHabits.take(3).toList();
  }

  static Map<String, double> _getTimeDistribution(List<Map<String, dynamic>> habits) {
    final timeSlots = {
      'Morning (6-12)': 0.0,
      'Afternoon (12-17)': 0.0,
      'Evening (17-22)': 0.0,
      'Night (22-6)': 0.0,
    };

    var total = 0;
    for (var habit in habits) {
      if (habit['reminderTime'] != null) {
        final time = DateTime.parse(habit['reminderTime']);
        final hour = time.hour;
        
        if (hour >= 6 && hour < 12) timeSlots['Morning (6-12)'] = timeSlots['Morning (6-12)']! + 1;
        else if (hour >= 12 && hour < 17) timeSlots['Afternoon (12-17)'] = timeSlots['Afternoon (12-17)']! + 1;
        else if (hour >= 17 && hour < 22) timeSlots['Evening (17-22)'] = timeSlots['Evening (17-22)']! + 1;
        else timeSlots['Night (22-6)'] = timeSlots['Night (22-6)']! + 1;
        
        total++;
      }
    }

    if (total > 0) {
      timeSlots.forEach((key, value) {
        timeSlots[key] = value / total;
      });
    }

    return timeSlots;
  }
} 