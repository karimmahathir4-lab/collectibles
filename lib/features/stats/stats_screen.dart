import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final artworksAsync = ref.watch(artworksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: artworksAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (artworks) {
          if (artworks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurface
                            : AppTheme.lightSurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder,
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.chart_pie,
                        size: 36,
                        color: AppTheme.accentWarm,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Analytics Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Document artworks and collectibles to view automated valuations and medium distribution.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final totalPieces = artworks.length;
          final totalEstimatedValue = artworks.fold<double>(
            0.0,
            (sum, a) => sum + (a.estimatedValue ?? 0.0),
          );
          final totalPurchaseCost = artworks.fold<double>(
            0.0,
            (sum, a) => sum + (a.purchasePrice ?? 0.0),
          );
          final valueAppreciation = totalEstimatedValue - totalPurchaseCost;

          // Medium breakdown
          final mediumCount = <String, int>{};
          for (final a in artworks) {
            final med = (a.medium != null && a.medium!.trim().isNotEmpty)
                ? a.medium!.trim()
                : 'Other / Craft';
            mediumCount[med] = (mediumCount[med] ?? 0) + 1;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Value summary card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VAULT VALUATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.accentWarm,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalEstimatedValue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatMetric(
                          'Total Pieces',
                          '$totalPieces',
                          isDark,
                        ),
                        _buildStatMetric(
                          'Capital Invested',
                          '\$${totalPurchaseCost.toStringAsFixed(0)}',
                          isDark,
                        ),
                        _buildStatMetric(
                          'Unrealized Gain',
                          '${valueAppreciation >= 0 ? '+' : ''}\$${valueAppreciation.toStringAsFixed(0)}',
                          isDark,
                          highlight: valueAppreciation >= 0
                              ? Colors.green
                              : Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Chart: Breakdown by Medium
              const Text(
                'Medium Distribution',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 36,
                    sections: _buildPieSections(mediumCount),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: mediumCount.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurface
                          : AppTheme.lightSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.lightBorder,
                      ),
                    ),
                    child: Text(
                      '${e.key}: ${e.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatMetric(
    String label,
    String value,
    bool isDark, {
    Color? highlight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color:
                highlight ??
                (isDark ? Colors.white : AppTheme.lightTextPrimary),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> counts) {
    final colors = [
      AppTheme.accentWarm,
      const Color(0xFF4A90E2),
      const Color(0xFF50E3C2),
      const Color(0xFFF5A623),
      const Color(0xFFBD10E0),
      const Color(0xFF9013FE),
    ];

    int index = 0;
    return counts.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.value}',
        color: color,
        radius: 46,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      );
    }).toList();
  }
}
