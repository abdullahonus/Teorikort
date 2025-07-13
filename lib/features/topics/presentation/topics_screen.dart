import 'package:flutter/material.dart';
import '../data/models/topic.dart';
import '../data/services/topic_service.dart';
import 'topic_detail_screen.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final TopicService _topicService = TopicService();
  List<Topic> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final response = await _topicService.getTopics();
      setState(() {
        _topics = response.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading topics: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalization.of(context).translate('topics.error') ??
                    'An error occurred while loading topics'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to get text in current language
  String _getLocalizedText(Map<String, String> textMap) {
    final currentLanguage = AppLocalization.of(context).locale.languageCode;
    return textMap[currentLanguage] ?? textMap['tr'] ?? textMap.values.first;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            )
          : _topics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalization.of(context)
                                .translate('topics.no_topics') ??
                            'No topics available',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _loadTopics,
                        icon: Icon(Icons.refresh, color: colorScheme.primary),
                        label: Text(
                          AppLocalization.of(context)
                                  .translate('common.retry') ??
                              'Retry',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        AppLocalization.of(context)
                                .translate('topics.subtitle') ??
                            'Learn about driving rules and regulations',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadTopics,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _topics.length,
                          itemBuilder: (context, index) {
                            final topic = _topics[index];
                            return _buildTopicCard(topic);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTopicCard(Topic topic) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopicDetailScreen(topic: topic),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: topic.imageUrl != null && topic.imageUrl!.isNotEmpty
                      ? Image.network(
                          topic.imageUrl!,
                          width: 32,
                          height: 32,
                          color: colorScheme.primary,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.menu_book,
                            color: colorScheme.primary,
                            size: 32,
                          ),
                        )
                      : Icon(
                          Icons.menu_book,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.getTitle(
                          AppLocalization.of(context).locale.languageCode),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.getDescription(
                          AppLocalization.of(context).locale.languageCode),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          context,
                          '${topic.subTopics.length} ${AppLocalization.of(context).translate('topics.subtopics') ?? 'subtopics'}',
                          Icons.menu_book_outlined,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          context,
                          '${topic.images.length} ${AppLocalization.of(context).translate('topics.images') ?? 'images'}',
                          Icons.image_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
