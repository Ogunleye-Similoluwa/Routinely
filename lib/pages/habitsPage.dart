import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_speed_code/services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class Habitspage extends StatefulWidget {
  final List<Map<String, dynamic>> habits;
  final VoidCallback onHabitsChanged;
  
  const Habitspage({
    Key? key, 
    required this.habits, 
    required this.onHabitsChanged
  }) : super(key: key);

  @override
  State<Habitspage> createState() => _HabitspageState();
}

class _HabitspageState extends State<Habitspage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SharedPreferences prefs;
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Health', 'Learning', 'Work', 'Personal'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  List<Map<String, dynamic>> getFilteredHabits() {
    if (selectedCategory == 'All') return widget.habits;
    return widget.habits.where((h) => h['category'] == selectedCategory).toList();
  }

  double getCompletionRate() {
    if (widget.habits.isEmpty) return 0.0;
    final completed = widget.habits.where((h) => h['completed']).length;
    return completed / widget.habits.length;
  }

  List<Map<String, dynamic>> getUpcomingHabits() {
    final now = DateTime.now();
    return widget.habits.where((h) {
      if (h['reminderTime'] == null) return false;
      final reminderTime = DateTime.parse(h['reminderTime']);
      return reminderTime.isAfter(now);
    }).toList()
      ..sort((a, b) => DateTime.parse(a['reminderTime'])
          .compareTo(DateTime.parse(b['reminderTime'])));
  }

  Map<String, double> getTimeDistribution() {
    final distribution = {'Morning': 0.0, 'Afternoon': 0.0, 'Evening': 0.0};
    if (widget.habits.isEmpty) return distribution;

    for (var habit in widget.habits) {
      if (habit['reminderTime'] != null) {
        final time = DateTime.parse(habit['reminderTime']);
        final hour = time.hour;
        
        if (hour < 12) distribution['Morning'] = (distribution['Morning']! + 1);
        else if (hour < 17) distribution['Afternoon'] = (distribution['Afternoon']! + 1);
        else distribution['Evening'] = (distribution['Evening']! + 1);
      }
    }

    final total = distribution.values.reduce((a, b) => a + b);
    if (total > 0) {
      distribution.forEach((key, value) {
        distribution[key] = value / total;
      });
    }

    return distribution;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
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
              child: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Habit Insights",
                          style: TextStyle(
                            fontSize: 24,
                              fontWeight: FontWeight.bold,
                            color: Colors.white,
                        ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Track your progress and stay motivated",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.purple,
                  labelColor: Colors.purple,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'Week'),
                    Tab(text: 'Month'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Container(
          color: Colors.white,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDailyView(),
              _buildWeeklyView(),
              _buildMonthlyView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(category),
              onSelected: (selected) {
                setState(() => selectedCategory = category);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.purple.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? Colors.purple : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: Colors.purple,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyView() {
    final filteredHabits = getFilteredHabits();
    final completionRate = getCompletionRate();
    final upcomingHabits = getUpcomingHabits();
    final timeDistribution = getTimeDistribution();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryFilter(),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                "Today's Progress",
                "${(completionRate * 100).round()}%",
                Icons.trending_up,
                Colors.green,
              ),
              _buildStatCard(
                "Completed",
                "${widget.habits.where((h) => h['completed']).length}/${widget.habits.length}",
                Icons.check_circle,
                Colors.blue,
              ),
              _buildStatCard(
                "Streak",
                "${_getLongestStreak()} days",
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildStatCard(
                "Focus Time",
                "${_getTotalFocusTime()} hrs",
                Icons.timer,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Today's Habits",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildHabitsList(filteredHabits),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[900],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(List<Map<String, dynamic>> habits) {
    if (habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No habits yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first habit to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habits.length,
      itemBuilder: (context, index) => _buildHabitItem(habits[index]),
    );
  }

  Widget _buildHabitItem(Map<String, dynamic> habit) {
    final color = _getCategoryColor(habit['category']);
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getHabitIcon(habit['category']), color: color),
        ),
        title: Text(
          habit['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: habit['completed'] ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          habit['description'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Checkbox(
          value: habit['completed'],
          onChanged: (_) => _toggleHabit(habit),
          activeColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  int _getLongestStreak() {
    if (widget.habits.isEmpty) return 0;
    return widget.habits
        .map((h) => h['streak'] as int? ?? 0)
        .reduce((max, value) => max > value ? max : value);
  }

  int _getTotalFocusTime() {
    return widget.habits.where((h) => h['completed']).length * 2; // Assuming 2 hours per habit
  }

  void _toggleHabit(Map<String, dynamic> habit) {
    setState(() {
      habit['completed'] = !habit['completed'];
      if (habit['completed']) {
        habit['streak'] = (habit['streak'] as int? ?? 0) + 1;
      }
    });
    _saveHabits();
    widget.onHabitsChanged();
  }

  Widget _buildWeeklyView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInsightCard(
            title: "Weekly Streak",
            value: "5 Days",
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildCompletionChart(widget.habits),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    final insights = AnalyticsService.generateInsights(widget.habits);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightsSummary(insights),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(insights['categoryBreakdown']),
          const SizedBox(height: 24),
          _buildCompletionCalendar(),
          const SizedBox(height: 24),
          _buildTrendAnalysis(insights['completionTrends']),
        ],
      ),
    );
  }

  Widget _buildInsightsSummary(Map<String, dynamic> insights) {
    final streakData = insights['streakData'] as Map<String, dynamic>? ?? {
      'currentStreak': 0,
      'averageStreak': 0,
      'totalCompletions': 0,
    };
    final trends = insights['completionTrends'] as List<dynamic>? ?? [];
    final completion = trends.isEmpty ? 0.0 : (trends.last['completion'] as double? ?? 0.0);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          "Best Streak",
          "${streakData['currentStreak']} days",
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildStatCard(
          "Average Streak",
          "${streakData['averageStreak']} days",
          Icons.analytics,
          Colors.blue,
        ),
        _buildStatCard(
          "Total Completions",
          "${streakData['totalCompletions']}",
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          "Success Rate",
          "${(completion * 100).round()}%",
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(Map<String, double> categoryData) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Category Breakdown",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryData.entries.map((e) => PieChartSectionData(
                    value: e.value * 100,
                    title: '${(e.value * 100).round()}%',
                    color: _getCategoryColor(e.key),
                    radius: 100,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...categoryData.entries.map((e) => _buildCategoryLegendItem(
              e.key,
              e.value,
              _getCategoryColor(e.key),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendAnalysis(List<Map<String, dynamic>> trends) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Completion Trends",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.2,
                        getTitlesWidget: (value, meta) {
                          return Text('${(value * 100).round()}%',
                            style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= trends.length) return const Text('');
                          final date = trends[value.toInt()]['date'] as DateTime;
                          return Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: trends.asMap().entries.map((e) => 
                        FlSpot(e.key.toDouble(), e.value['completion'])).toList(),
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.purple.withOpacity(0.1),
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

  Widget _buildUpcomingHabits(List<Map<String, dynamic>> upcomingHabits) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Coming Up",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("See All"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...upcomingHabits.take(3).map((habit) {
              final reminderTime = DateTime.parse(habit['reminderTime']);
              return _buildUpcomingHabitItem(
                habit['name'],
                "${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}",
                _getHabitIcon(habit['category']),
                _getCategoryColor(habit['category']),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingHabitItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            color: Colors.grey[600],
          ),
        ],
        ),
      );
    }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Health': return Colors.green;
      case 'Learning': return Colors.blue;
      case 'Work': return Colors.orange;
      case 'Personal': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getHabitIcon(String category) {
    switch (category) {
      case 'Health': return Icons.favorite;
      case 'Learning': return Icons.school;
      case 'Work': return Icons.work;
      case 'Personal': return Icons.person;
      default: return Icons.star;
    }
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionChart(List<Map<String, dynamic>> filteredHabits) {
    // Calculate completion rate for each hour
    final hourlyCompletion = List.generate(6, (index) {
      final hour = index * 3 + 6; // 6AM to 9PM in 3-hour intervals
      final habitsInHour = filteredHabits.where((h) {
        if (h['lastCompleted'] == null) return false;
        final completedTime = DateTime.parse(h['lastCompleted']);
        return completedTime.hour >= hour && completedTime.hour < (hour + 3);
      });
      return habitsInHour.length / (filteredHabits.isEmpty ? 1 : filteredHabits.length) * 100;
    });

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Completion Rate",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%',
                            style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const hours = ['6AM', '9AM', '12PM', '3PM', '6PM', '9PM'];
                          if (value.toInt() < hours.length) {
                            return Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                hours[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: hourlyCompletion
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.purple,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.purple.withOpacity(0.1),
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

  Widget _buildTimeDistributionCard(Map<String, double>? timeDistribution) {
    final distribution = timeDistribution ?? {
      'Morning': 0.0,
      'Afternoon': 0.0,
      'Evening': 0.0,
    };
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text("Time Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTimeRow("Morning", distribution['Morning']!, Colors.orange),
          const SizedBox(height: 12),
          _buildTimeRow("Afternoon", distribution['Afternoon']!, Colors.blue),
          const SizedBox(height: 12),
          _buildTimeRow("Evening", distribution['Evening']!, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String time, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time),
            Text('${(progress * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildCompletionCalendar() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now(),
          focusedDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(formatButtonVisible: false),
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
            ),
          ),
          eventLoader: (day) {
            return widget.habits.where((h) {
              if (h['lastCompleted'] == null) return false;
              final completed = DateTime.parse(h['lastCompleted']);
              return completed.year == day.year && 
                     completed.month == day.month && 
                     completed.day == day.day;
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildCategoryLegendItem(String category, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(category),
          const Spacer(),
          Text('${(percentage * 100).round()}%'),
        ],
      ),
    );
  }

  Future<void> _saveHabits() async {
    await prefs.setString('habits', json.encode(widget.habits));
  }
}
