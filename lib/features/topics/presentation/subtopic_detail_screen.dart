import 'package:flutter/material.dart';
import '../data/models/topic.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:flutter_html/flutter_html.dart';

class SubtopicDetailScreen extends StatefulWidget {
  final Topic topic;
  final SubTopic subTopic;

  const SubtopicDetailScreen({
    super.key,
    required this.topic,
    required this.subTopic,
  });

  @override
  State<SubtopicDetailScreen> createState() => _SubtopicDetailScreenState();
}

class _SubtopicDetailScreenState extends State<SubtopicDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.subTopic.title,
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subTopic.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Html(
            data: widget.subTopic.content,
            style: {
              "body": Style(
                fontSize: FontSize(16),
                lineHeight: const LineHeight(1.6),
                color: colorScheme.onSurface.withOpacity(0.8),
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              "h3": Style(
                fontSize: FontSize(20),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 12),
              ),
              "h4": Style(
                fontSize: FontSize(18),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 8, top: 16),
              ),
              "p": Style(
                margin: Margins.only(bottom: 12),
              ),
              "ul": Style(
                margin: Margins.only(bottom: 16, left: 20),
              ),
              "li": Style(
                margin: Margins.only(bottom: 8),
              ),
              ".image-container": Style(
                alignment: Alignment.center,
                margin: Margins.symmetric(vertical: 16),
              ),
              "img": Style(
                alignment: Alignment.center,
                width: Width(300),
                backgroundColor: Colors.transparent,
              ),
            },
            onLinkTap: (url, _, __) {
              if (url != null) {
                debugPrint('Tapped url: $url');
              }
            },
          ),
        ],
      ),
    );
  }
}
