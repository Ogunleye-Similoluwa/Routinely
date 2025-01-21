import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartBase extends StatelessWidget {
  const ChartBase({
    super.key,
    required this.isShowingMainData,
    required this.title,
    required this.color,
    required this.spots,
  });

  final bool isShowingMainData;
  final String title;
  final Color color;
  final List<FlSpot> spots;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 15),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 37),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, left: 6),
                    child: _LineChart(
                      isShowingMainData: isShowingMainData,
                      color: color,
                      spots: spots,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.isShowingMainData,
    required this.color,
    required this.spots,
  });

  final bool isShowingMainData;
  final Color color;
  final List<FlSpot> spots;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      sampleData1,
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData get sampleData1 => LineChartData(
        lineTouchData: lineTouchData1,
        gridData: gridData,
        titlesData: titlesData1,
        borderData: borderData,
        lineBarsData: lineBarsData1,
        minX: 0,
        maxX: 14,
        maxY: 100,
        minY: 0,
      );

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              return LineTooltipItem(
                '${touchedSpot.y.round()}%',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
          tooltipBgColor: Colors.black.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        LineChartBarData(
          isCurved: true,
          color: color,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: spots,
        ),
      ];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );
    return Text('${value.toInt()}%',
        style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('SEPT', style: style);
        break;
      case 7:
        text = const Text('OCT', style: style);
        break;
      case 12:
        text = const Text('DEC', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      child: text,
      axisSide: meta.axisSide,
      space: 10,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: Colors.black),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );
}

// Sample chart implementations
class LineChartSample1 extends StatelessWidget {
  const LineChartSample1({super.key});

  @override
  Widget build(BuildContext context) {
    return ChartBase(
      isShowingMainData: true,
      title: 'Reading Books',
      color: Colors.purple,
      spots: const [
        FlSpot(1, 25),
        FlSpot(3, 35),
        FlSpot(5, 40),
        FlSpot(7, 48),
        FlSpot(10, 53),
        FlSpot(12, 75),
        FlSpot(13, 70),
      ],
    );
  }
}

class LineChartSample2 extends StatelessWidget {
  const LineChartSample2({super.key});

  @override
  Widget build(BuildContext context) {
    return ChartBase(
      isShowingMainData: true,
      title: 'Exercise',
      color: Colors.deepPurpleAccent,
      spots: const [
        FlSpot(1, 86),
        FlSpot(3, 78),
        FlSpot(5, 75),
        FlSpot(7, 63),
        FlSpot(10, 74),
        FlSpot(12, 85),
        FlSpot(13, 92),
      ],
    );
  }
}

class LineChartSample3 extends StatelessWidget {
  const LineChartSample3({super.key});

  @override
  Widget build(BuildContext context) {
    return ChartBase(
      isShowingMainData: true,
      title: 'Drink Water',
      color: Colors.purpleAccent,
      spots: const [
        FlSpot(1, 50),
        FlSpot(3, 52),
        FlSpot(5, 45),
        FlSpot(7, 57),
        FlSpot(10, 86),
        FlSpot(12, 88),
        FlSpot(13, 90),
      ],
    );
  }
}

class HabitAnalytics extends StatelessWidget {
  final List<Map<String, dynamic>> habits;

  const HabitAnalytics({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, 
              size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No habits yet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add habits to see your progress',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCompletionRateCard(),
        const SizedBox(height: 16),
        _buildCategoryDistributionCard(),
        const SizedBox(height: 16),
        _buildStreakLeaderboardCard(),
        const SizedBox(height: 16),
        _buildWeeklyProgressChart(),
      ],
    );
  }

  Widget _buildCompletionRateCard() {
    final completedCount = habits.where((h) => h['completed']).length;
    final completionRate = habits.isEmpty ? 0 : (completedCount / habits.length * 100);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Completion Rate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: completionRate / 100,
                        backgroundColor: Colors.grey[200],
                        strokeWidth: 12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                      Center(
                        child: Text(
                          '${completionRate.round()}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow('Total Habits', habits.length.toString()),
                      const SizedBox(height: 8),
                      _buildStatRow('Completed', completedCount.toString()),
                      const SizedBox(height: 8),
                      _buildStatRow('Remaining', (habits.length - completedCount).toString()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionCard() {
    final categoryCount = <String, int>{};
    for (var habit in habits) {
      final category = habit['category'] as String? ?? 'Personal';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Habits by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categoryCount.entries.map((e) => Column(
              children: [
                LinearProgressIndicator(
                  value: e.value / habits.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(e.key)),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key),
                    Text('${(e.value / habits.length * 100).round()}%'),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakLeaderboardCard() {
    final sortedHabits = [...habits]..sort((a, b) => 
        (b['streak'] as int? ?? 0).compareTo(a['streak'] as int? ?? 0));
    final topHabits = sortedHabits.take(3).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Streaks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...topHabits.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _buildMedal(e.key),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value['name'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, 
                        color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${e.value['streak'] ?? 0} days',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressChart() {
    // Calculate completion rates for the last 7 days
    final weeklyData = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final dayHabits = habits.where((h) {
        if (h['lastCompleted'] == null) return false;
        final completedDate = DateTime.parse(h['lastCompleted']);
        return completedDate.year == date.year && 
               completedDate.month == date.month && 
               completedDate.day == date.day;
      });
      
      return dayHabits.isEmpty ? 0.0 : 
             (dayHabits.length / habits.length) * 100;
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Last 7 Days',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                        final date = DateTime.now()
                            .subtract(Duration(days: 6 - value.toInt()));
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
                    spots: weeklyData.asMap().entries
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
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMedal(int index) {
    final colors = [Colors.amber, Colors.grey[300], Colors.brown[300]];
    final icons = ['🥇', '🥈', '🥉'];
    
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: colors[index]?.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(icons[index])),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Personal':
        return Colors.blue;
      case 'Work':
        return Colors.green;
      case 'Health':
        return Colors.red;
      case 'Learning':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }
}
