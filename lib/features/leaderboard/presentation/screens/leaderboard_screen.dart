import 'package:flutter/material.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:driving_license_exam/features/leaderboard/data/models/leaderboard_entry.dart';
import 'package:driving_license_exam/features/leaderboard/data/services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  late Future<List<LeaderboardEntry>?> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    setState(() {
      _leaderboardFuture = _leaderboardService
          .getLeaderboard()
          .then((response) => response.data?.leaderboard);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalization.of(context).translate('leaderboard.screen_title'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: FutureBuilder<List<LeaderboardEntry>?>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalization.of(context)
                            .translate('leaderboard.error_message') ??
                        'Unable to load leaderboard',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _loadLeaderboard,
                    icon: Icon(Icons.refresh, color: colorScheme.primary),
                    label: Text(
                      AppLocalization.of(context)
                              .translate('leaderboard.refresh') ??
                          'Refresh',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                ],
              ),
            );
          }

          final entries = snapshot.data;
          if (entries == null || entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalization.of(context)
                            .translate('leaderboard.no_data') ??
                        'No leaderboard data available',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalization.of(context)
                            .translate('leaderboard.take_exams_first') ??
                        'Take some exams to see rankings',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalization.of(context)
                          .translate('leaderboard.top_performers'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            AppLocalization.of(context)
                                .translate('leaderboard.rank'),
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            AppLocalization.of(context)
                                .translate('leaderboard.user'),
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          AppLocalization.of(context)
                              .translate('leaderboard.score'),
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              final entry = entries[index - 1];
              return _buildLeaderboardItem(entry);
            },
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color getRankColor() {
      switch (entry.rank) {
        case 1:
          return const Color(0xFFFFD700); // Gold
        case 2:
          return const Color(0xFFC0C0C0); // Silver
        case 3:
          return const Color(0xFFCD7F32); // Bronze
        default:
          return colorScheme.onSurface.withOpacity(0.6);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isCurrentUser
              ? colorScheme.primary.withOpacity(0.2)
              : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: entry.rank <= 3
                  ? getRankColor().withOpacity(0.1)
                  : colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                color: entry.rank <= 3 ? getRankColor() : colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                entry.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.score} ${AppLocalization.of(context).translate('leaderboard.points')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (entry.rank <= 3)
            Icon(
              Icons.emoji_events,
              color: getRankColor(),
              size: 24,
            ),
        ],
      ),
    );
  }
}
