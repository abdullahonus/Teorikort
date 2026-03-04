import 'package:flutter/material.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/features/leaderboard/data/models/leaderboard_entry.dart';
import 'package:teorikort/features/leaderboard/data/services/leaderboard_service.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  late Future<List<LeaderboardEntry>?> _leaderboardFuture;
  late Future<LeaderboardEntry?> _myRankFuture;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    setState(() {
      _leaderboardFuture = _leaderboardService
          .getLeaderboard(context: context)
          .then((r) => r.data);
      _myRankFuture = _leaderboardService
          .getMyRank(context: context)
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
              child: const AppLoadingWidget(),
            );
          }

          if (snapshot.hasError) {
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
                        .translate('leaderboard.error_message'),
                    style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _loadLeaderboard,
                    icon: Icon(Icons.refresh, color: colorScheme.primary),
                    label: Text(
                      AppLocalization.of(context)
                          .translate('leaderboard.refresh'),
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
                  Icon(Icons.emoji_events_outlined,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalization.of(context)
                        .translate('leaderboard.no_data'),
                    style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalization.of(context)
                        .translate('leaderboard.take_exams_first'),
                    style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // My-rank banner — always from dedicated API, shown when rank > 3
          return Column(
            children: [
              FutureBuilder<LeaderboardEntry?>(
                future: _myRankFuture,
                builder: (ctx, snap) {
                  final myRank = snap.data;
                  if (myRank == null || myRank.rank <= 3) {
                    return const SizedBox.shrink();
                  }
                  return _buildCurrentUserBanner(myRank);
                },
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: entries.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildHeader();
                    return _buildLeaderboardItem(entries[index - 1]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              AppLocalization.of(context).translate('leaderboard.rank'),
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalization.of(context).translate('leaderboard.user'),
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
            ),
          ),
          Text(
            AppLocalization.of(context).translate('leaderboard.score'),
            style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserBanner(LeaderboardEntry entry) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sıralamanız: #${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
          Text(
            '${entry.score} puan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    final colorScheme = Theme.of(context).colorScheme;

    Color getRankColor() {
      switch (entry.rank) {
        case 1:
          return const Color(0xFFFFD700); // Gold
        case 2:
          return const Color(0xFFC0C0C0); // Silver
        case 3:
          return const Color(0xFFCD7F32); // Bronze
        default:
          return colorScheme.onSurface.withOpacity(0.5);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? colorScheme.primary.withOpacity(0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isCurrentUser
              ? colorScheme.primary.withOpacity(0.25)
              : colorScheme.outline.withOpacity(0.15),
          width: entry.isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank circle
          SizedBox(
            width: 40,
            child: entry.rank <= 3
                ? Icon(Icons.emoji_events,
                    color: getRankColor(), size: 26)
                : Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${entry.rank}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 10),

          // Avatar initials
          CircleAvatar(
            radius: 18,
            backgroundColor: entry.isCurrentUser
                ? colorScheme.primary
                : colorScheme.primary.withOpacity(0.15),
            child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: entry.isCurrentUser
                    ? colorScheme.onPrimary
                    : colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: entry.isCurrentUser
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.totalExams} sınav  •  ort. %${entry.averageScore.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Score badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: entry.rank <= 3
                  ? getRankColor().withOpacity(0.12)
                  : colorScheme.primary.withOpacity(0.09),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${entry.score}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: entry.rank <= 3 ? getRankColor() : colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
