import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseCharts extends StatelessWidget {
  final Map<String, double> categoryBreakdown;
  final String currencySymbol;

  const ExpenseCharts({
    super.key,
    required this.categoryBreakdown,
    required this.currencySymbol,
  });

  Color _getCategoryColor(String category, ColorScheme colorScheme) {
    switch (category) {
      case 'Flights':
        return colorScheme.primary;
      case 'Stays':
        return colorScheme.secondary;
      case 'Food':
        return colorScheme.tertiary;
      case 'Transport':
        return Colors.tealAccent.shade700;
      case 'Gear':
        return Colors.orangeAccent.shade700;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = categoryBreakdown.keys.toList();
    final values = categoryBreakdown.values.toList();
    final total = values.fold<double>(0.0, (sum, v) => sum + v);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'CATEGORY ALLOCATION',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total: $currencySymbol${total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: total <= 0
                      ? Center(
                          child: Text(
                            'No expenses logged yet.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY:
                                (values.reduce((a, b) => a > b ? a : b) * 1.25)
                                    .clamp(100.0, double.infinity),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) =>
                                    colorScheme.surfaceContainerHighest,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final cat = categories[group.x.toInt()];
                                  return BarTooltipItem(
                                    '$cat\n$currencySymbol${rod.toY.toStringAsFixed(0)}',
                                    TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                  reservedSize: 0,
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                  reservedSize: 0,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  getTitlesWidget: (val, meta) {
                                    return Text(
                                      val.toInt().toString(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 26,
                                  getTitlesWidget: (val, meta) {
                                    final index = val.toInt();
                                    if (index >= 0 &&
                                        index < categories.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          categories[index].substring(0, 3),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (val) => FlLine(
                                color: colorScheme.outlineVariant,
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(categories.length, (i) {
                              final amount = values[i];
                              final color = _getCategoryColor(
                                categories[i],
                                colorScheme,
                              );
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: amount,
                                    color: color,
                                    width: 22,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: categories.map((cat) {
                    final color = _getCategoryColor(cat, colorScheme);
                    final amt = categoryBreakdown[cat] ?? 0.0;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$cat: $currencySymbol${amt.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
