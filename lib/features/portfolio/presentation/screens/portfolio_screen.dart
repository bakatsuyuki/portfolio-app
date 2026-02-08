import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/price_history_entry.dart';
import '../../../../shared/widgets/error_retry_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/app_data.dart';
import '../providers/portfolio_providers.dart';

/// ポートフォリオ画面（サマリー・保有株式・セクター円グラフ）。
class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioDataProvider);

    return Scaffold(
      body: Container(
        decoration: AppTheme.darkBackgroundGradient,
        child: SafeArea(
          child: portfolioAsync.when(
            data: (AppData data) {
              final priceHistoryAsync = ref.watch(priceHistoryMapProvider);
              final priceHistoryMap = priceHistoryAsync.whenOrNull(
                data: (Map<String, List<PriceHistoryEntry>> m) => m,
              );
              return _PortfolioContent(
                data: data,
                priceHistoryMap: priceHistoryMap,
              );
            },
            loading: () => const LoadingView(),
            error: (Object e, StackTrace _) {
              if (e is DataNotFoundException &&
                  e.message.contains('Drive フォルダが選択されていません')) {
                return _FolderNotSelectedView(
                  onOpenSettings: () => context.goNamed('settings'),
                );
              }
              return ErrorRetryView(
                message: e.toString(),
                onRetry: () => ref.invalidate(portfolioDataProvider),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FolderNotSelectedView extends StatelessWidget {
  const _FolderNotSelectedView({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Drive フォルダが選択されていません',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '設定で app_data.json を含むフォルダを選択してください。',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings),
              label: const Text('設定でフォルダを選択'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioContent extends StatelessWidget {
  const _PortfolioContent({
    required this.data,
    this.priceHistoryMap,
  });

  final AppData data;
  final Map<String, List<PriceHistoryEntry>>? priceHistoryMap;

  @override
  Widget build(BuildContext context) {
    final totalUsd =
        data.holdings.fold<num>(0, (num sum, h) => sum + h.valueUsd);
    final totalJpy =
        data.holdings.fold<num>(0, (num sum, h) => sum + h.valueJpy);

    return CustomScrollView(
      slivers: <Widget>[
        const SliverAppBar(
          title: Text(AppConstants.appName),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                _SummaryCard(totalUsd: totalUsd, totalJpy: totalJpy),
                const SizedBox(height: 24),
                const Text(
                  'セクター配分',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _SectorPieChart(sectorAllocation: data.sectorAllocation),
                const SizedBox(height: 24),
                const Text(
                  '保有株式',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...data.holdings.map(
                  (h) {
                    final history = priceHistoryMap?[h.symbol];
                    return _HoldingTile(
                      symbol: h.symbol,
                      price: h.price,
                      valueUsd: h.valueUsd,
                      valueJpy: h.valueJpy,
                      ratio: h.ratio,
                      sector: () {
                        final list = data.sectors
                            .where((s) => s.symbol == h.symbol)
                            .toList();
                        return list.isEmpty ? null : list.first.sector;
                      }(),
                      priceHistory: history,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalUsd,
    required this.totalJpy,
  });

  final num totalUsd;
  final num totalJpy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '合計評価額',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${totalUsd.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '¥${totalJpy.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SectorPieChart extends StatelessWidget {
  const _SectorPieChart({required this.sectorAllocation});

  final Map<String, num> sectorAllocation;

  static const List<Color> _colors = <Color>[
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFFFEAA7),
    Color(0xFFDDA0DD),
    Color(0xFF98D8C8),
  ];

  @override
  Widget build(BuildContext context) {
    if (sectorAllocation.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'セクターデータがありません',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final entries = sectorAllocation.entries.toList();
    final spots = entries.asMap().entries.map((e) {
      final i = e.key;
      final ratio = e.value.value.toDouble();
      return PieChartSectionData(
        value: ratio,
        title: '${ratio.toStringAsFixed(0)}%',
        color: _colors[i % _colors.length],
        radius: 80,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: PieChart(
              PieChartData(
                sections: spots,
                sectionsSpace: 2,
                centerSpaceRadius: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.asMap().entries.map((e) {
                final i = e.key;
                final name = e.value.key;
                final ratio = e.value.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _colors[i % _colors.length],
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${ratio.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoldingTile extends StatelessWidget {
  const _HoldingTile({
    required this.symbol,
    required this.price,
    required this.valueUsd,
    required this.valueJpy,
    required this.ratio,
    this.sector,
    this.priceHistory,
  });

  final String symbol;
  final num price;
  final num valueUsd;
  final num valueJpy;
  final num ratio;
  final String? sector;
  final List<PriceHistoryEntry>? priceHistory;

  @override
  Widget build(BuildContext context) {
    final previousPrice = priceHistory != null && priceHistory!.length >= 2
        ? priceHistory![priceHistory!.length - 2].price
        : null;
    final changePercent = previousPrice != null && previousPrice != 0
        ? ((price - previousPrice) / previousPrice) * 100
        : null;
    final hasTrend = priceHistory != null && priceHistory!.length >= 2;

    return InkWell(
      onTap: () => _showHoldingPriceDetail(
        context,
        symbol: symbol,
        sector: sector,
        price: price,
        valueUsd: valueUsd,
        priceHistory: priceHistory,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        symbol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (sector != null)
                        Text(
                          sector!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '\$${valueUsd.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '${ratio.toStringAsFixed(1)}%',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '価格 \$${price.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            if (previousPrice != null) ...[
              const SizedBox(height: 2),
              Text(
                '前回 \$${previousPrice.toStringAsFixed(2)} → 今回 \$${price.toStringAsFixed(2)}'
                '${changePercent != null ? " (${changePercent >= 0 ? "+" : ""}${changePercent.toStringAsFixed(1)}%)" : ""}',
                style: TextStyle(
                  color: changePercent != null
                      ? (changePercent >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent)
                      : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
            if (hasTrend && priceHistory!.length >= 2) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: _PriceSparkline(entries: priceHistory!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static void _showHoldingPriceDetail(
    BuildContext context, {
    required String symbol,
    required num price,
    required num valueUsd,
    String? sector,
    List<PriceHistoryEntry>? priceHistory,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _HoldingPriceDetailSheet(
        symbol: symbol,
        sector: sector,
        price: price,
        valueUsd: valueUsd,
        priceHistory: priceHistory,
      ),
    );
  }
}

class _PriceSparkline extends StatelessWidget {
  const _PriceSparkline({required this.entries});

  final List<PriceHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) return const SizedBox.shrink();
    final prices = entries.map((e) => e.price.toDouble()).toList();
    final minP = prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.reduce((a, b) => a > b ? a : b);
    final range = maxP - minP;
    final normalized = range > 0
        ? prices.map((p) => (p - minP) / range).toList()
        : List<double>.filled(prices.length, 0.5);
    final spots = normalized.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), 1 - e.value);
    }).toList();
    return LineChart(
      LineChartData(
        lineTouchData: const LineTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: 0,
        maxY: 1,
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF4ECDC4),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}

/// 個別銘柄の価格推移を表示するボトムシート。
class _HoldingPriceDetailSheet extends StatelessWidget {
  const _HoldingPriceDetailSheet({
    required this.symbol,
    required this.price,
    required this.valueUsd,
    this.sector,
    this.priceHistory,
  });

  final String symbol;
  final num price;
  final num valueUsd;
  final String? sector;
  final List<PriceHistoryEntry>? priceHistory;

  @override
  Widget build(BuildContext context) {
    final hasTrend = priceHistory != null && priceHistory!.length >= 2;
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          symbol,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        if (sector != null)
                          Text(
                            sector!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '評価 \$${valueUsd.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '価格の推移',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: hasTrend
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _PriceDetailChart(entries: priceHistory!),
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          '2回以上の取得で推移を表示します。\nアプリを開くたびに更新されます。',
                          style: TextStyle(color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 個別銘柄用の価格推移チャート（日付ラベル付き）。
class _PriceDetailChart extends StatelessWidget {
  const _PriceDetailChart({required this.entries});

  final List<PriceHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) return const SizedBox.shrink();
    final prices = entries.map((e) => e.price.toDouble()).toList();
    final minP = prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.reduce((a, b) => a > b ? a : b);
    final range = maxP - minP;
    final pad = range > 0 ? range * 0.05 : 1.0;
    final minY = minP - pad;
    final maxY = maxP + pad;
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.price.toDouble());
    }).toList();
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot spot) {
                final i = spot.x.toInt();
                if (i < 0 || i >= entries.length) return null;
                final e = entries[i];
                final date = DateTime.fromMillisecondsSinceEpoch(e.timestampMs);
                final dateStr =
                    '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                return LineTooltipItem(
                  '$dateStr\n\$${e.price.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: range > 0 ? range / 4 : 1,
          getDrawingHorizontalLine: (double value) => const FlLine(
            color: Colors.white12,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: range > 0 ? range / 4 : 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (entries.length / 4).clamp(1.0, double.infinity),
              getTitlesWidget: (double value, TitleMeta meta) {
                final i = value.toInt();
                if (i < 0 || i >= entries.length) {
                  return const SizedBox.shrink();
                }
                final date =
                    DateTime.fromMillisecondsSinceEpoch(entries[i].timestampMs);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
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
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Colors.white24),
            bottom: BorderSide(color: Colors.white24),
          ),
        ),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF4ECDC4),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}
