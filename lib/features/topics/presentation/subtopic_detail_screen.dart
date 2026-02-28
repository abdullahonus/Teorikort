import 'package:flutter/material.dart';
import '../data/models/topic.dart';

/// Used when a subtopic is fetched separately (e.g. /topics/{id}/subtopics/{sid}).
/// Currently API only has flat topic content so this screen shows SubTopic.content.
class SubtopicDetailScreen extends StatelessWidget {
  final SubTopic subTopic;

  const SubtopicDetailScreen({
    super.key,
    required this.subTopic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          subTopic.title,
          style: theme.textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          subTopic.content,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.85),
            height: 1.7,
          ),
        ),
      ),
    );
  }
}
