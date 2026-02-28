import 'package:flutter/material.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import '../../data/models/statistics_data.dart';
import '../../data/services/statistics_service.dart';

class CategoryStatisticsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const CategoryStatisticsScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<CategoryStatisticsScreen> createState() =>
      _CategoryStatisticsScreenState();
}

class _CategoryStatisticsScreenState extends State<CategoryStatisticsScreen> {
  final StatisticsService _service = StatisticsService();
  Future<CategoryStatisticsData?>? _dataFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dataFuture == null) {
      _load();
    }
  }

  void _load() {
    setState(() {
      _dataFuture = _service
          .getCategoryStatistics(widget.categoryId, context: context)
          .then((r) => r.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: FutureBuilder<CategoryStatisticsData?>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64,
                        color: colorScheme.error.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalization.of(context)
                          .translate('statistics.error_message'),
                      style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _load,
                      icon: Icon(Icons.refresh, color: colorScheme.primary),
                      label: Text(
                        AppLocalization.of(context).translate('common.retry'),
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Summary cards row
                Row(
                  children: [
                    _statCard(
                      context,
                      icon: Icons.assignment_outlined,
                      label: 'Toplam Sınav',
                      value: '${data.totalExams}',
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      context,
                      icon: Icons.analytics_outlined,
                      label: 'Ortalama',
                      value: '%${data.averageScore.toStringAsFixed(1)}',
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      context,
                      icon: Icons.emoji_events_outlined,
                      label: 'En Yüksek',
                      value: '%${data.highestScore.toStringAsFixed(0)}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Score range card
                if (data.totalExams > 1) ...[
                  _buildScoreRangeCard(context, data),
                  const SizedBox(height: 24),
                ],

                // Recent exams list
                if (data.recentExams.isNotEmpty) ...[
                  Text(
                    'Son Sınavlar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...data.recentExams.map((exam) =>
                      _buildRecentExamItem(context, exam)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: colorScheme.primary.withOpacity(0.15), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRangeCard(
      BuildContext context, CategoryStatisticsData data) {
    final colorScheme = Theme.of(context).colorScheme;
    final avg = data.averageScore;
    final color = avg >= 80
        ? Colors.green
        : avg >= 60
            ? colorScheme.secondary
            : colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Puan Aralığı',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _rangeItem(context, 'En Düşük',
                  '%${data.lowestScore.toStringAsFixed(0)}', colorScheme.error),
              _rangeItem(context, 'Ortalama',
                  '%${data.averageScore.toStringAsFixed(1)}', color),
              _rangeItem(
                  context,
                  'En Yüksek',
                  '%${data.highestScore.toStringAsFixed(0)}',
                  Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (avg / 100).clamp(0.0, 1.0),
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangeItem(
      BuildContext context, String label, String value, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExamItem(
      BuildContext context, RecentExamResult exam) {
    final colorScheme = Theme.of(context).colorScheme;
    final score = exam.point;
    final color = score >= 80
        ? Colors.green
        : score >= 60
            ? colorScheme.secondary
            : colorScheme.error;

    final dateStr =
        '${exam.createdAt.day}.${exam.createdAt.month}.${exam.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: colorScheme.onSurface.withOpacity(0.4),
              size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dateStr,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '%${score.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
