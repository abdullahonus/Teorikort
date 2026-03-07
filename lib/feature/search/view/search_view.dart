import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/feature/exam/model/exam_question.dart';
import '../provider/search_provider.dart';
import 'search_question_detail_view.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (val) =>
              ref.read(searchProvider.notifier).onQueryChanged(val),
          decoration: InputDecoration(
            hintText: AppLocalization.of(context).translate('search.hint'),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchProvider.notifier).clearSearch();
                    },
                  )
                : null,
          ),
        ),
        bottom: state.isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              )
            : null,
      ),
      body: state.hasSearched
          ? _buildSearchResults(context, state)
          : _buildInitialContent(context),
    );
  }

  Widget _buildSearchResults(BuildContext context, state) {
    if (state.results.isEmpty && !state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 80,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              AppLocalization.of(context).translate('search.no_results'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final ExamQuestion question = state.results[index];
        return _SearchQuestionCard(question: question);
      },
    );
  }

  Widget _buildInitialContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalization.of(context).translate('search.categories'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCategoryChip(context, 'Trafik İşaretleri', Icons.traffic),
              _buildCategoryChip(context, 'Kavşak Kuralları', Icons.rule),
              _buildCategoryChip(context, 'İlk Yardım', Icons.medical_services),
              _buildCategoryChip(context, 'Araç Tekniği', Icons.car_repair),
              _buildCategoryChip(context, 'Hız Sınırları', Icons.speed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icon, size: 16, color: colorScheme.primary),
      label: Text(label),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      onPressed: () {
        _searchController.text = label;
        ref.read(searchProvider.notifier).onQueryChanged(label);
      },
    );
  }
}

class _SearchQuestionCard extends StatelessWidget {
  final ExamQuestion question;

  const _SearchQuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          question.question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalization.of(context).translate('quiz.correct_answer'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right,
            color: colorScheme.primary.withValues(alpha: 0.5)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SearchQuestionDetailView(question: question),
            ),
          );
        },
      ),
    );
  }
}
