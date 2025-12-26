import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'scrobble_distribution_component.dart';

class ScrobbleDistributionBarChart extends StatelessWidget {
  final ScrobbleDistributionLevel level;
  final List<ScrobbleDistributionItem> items;
  final void Function(ScrobbleDistributionItem) onTap;

  const ScrobbleDistributionBarChart({
    required this.level,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => BarChart(
    BarChartData(
      barGroups: [
        for (final (i, item) in items.indexed)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: item.scrobbles.toDouble(),
                color: Preferences.themeColor.value.color,
              ),
            ],
            showingTooltipIndicators: [0],
          ),
      ],
      alignment: .center,
      rotationQuarterTurns: 1,
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 72,
            getTitlesWidget: (_, _) => const SizedBox(),
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            maxIncluded: false,
            getTitlesWidget: (value, meta) =>
                SideTitleWidget(meta: meta, child: Text(meta.formattedValue)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              meta: meta,
              child: Text(items[value.toInt()].shortTitle),
            ),
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchCallback: (event, response) {
          if (event is! FlTapUpEvent && event is! FlLongPressEnd) {
            return;
          }
          final index = response?.spot?.touchedBarGroup.x;
          if (index != null) {
            onTap(items[index]);
          }
        },
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.transparent,
          getTooltipItem: (_, _, rod, _) => rod.toY == 0
              ? null
              : BarTooltipItem(
                  numberFormat.format(rod.toY),
                  Theme.of(context).textTheme.bodyMedium!,
                ),
        ),
      ),
      gridData: const FlGridData(drawVerticalLine: false),
      borderData: FlBorderData(show: false),
    ),
  );
}
