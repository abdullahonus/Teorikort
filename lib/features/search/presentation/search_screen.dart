import 'package:flutter/material.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  bool _isSearching = false;

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      // TODO: Implement actual search logic
      _searchResults = query.isEmpty
          ? []
          : [
              'Trafik İşaretleri',
              'Trafik Kuralları',
              'İlk Yardım',
              'Motor ve Araç Tekniği',
            ]
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: AppLocalization.of(context).translate('search.hint'),
            border: InputBorder.none,
            suffixIcon: _isSearching
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _isSearching ? _buildSearchResults() : _buildInitialContent(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(AppLocalization.of(context).translate('search.no_results')),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(_searchResults[index]),
          onTap: () {
            // TODO: Navigate to the selected topic/question
          },
        );
      },
    );
  }

  Widget _buildInitialContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalization.of(context).translate('search.categories'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip(
                  'exam_categories.traffic_signs', Icons.traffic),
              _buildCategoryChip('exam_categories.traffic_rules', Icons.rule),
              _buildCategoryChip(
                  'exam_categories.first_aid', Icons.medical_services),
              _buildCategoryChip(
                  'exam_categories.vehicle_tech', Icons.car_repair),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String labelKey, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(AppLocalization.of(context).translate(labelKey)),
      onPressed: () {
        _searchController.text =
            AppLocalization.of(context).translate(labelKey);
        _onSearchChanged(_searchController.text);
      },
    );
  }
}
