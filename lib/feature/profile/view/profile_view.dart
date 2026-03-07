import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/providers/locale_provider.dart';
import 'package:teorikort/core/providers/theme_provider.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';
import 'package:teorikort/feature/auth/provider/auth_provider.dart';
import 'package:teorikort/feature/profile/provider/profile_provider.dart';
import 'package:teorikort/feature/splash/provider/splash_provider.dart';
import 'package:teorikort/feature/splash/splash_view.dart';
import 'package:teorikort/features/packages/presentation/packages_screen.dart';
import 'package:teorikort/features/workbook/presentation/workbook_list_screen.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editProfilePhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      messenger.showSnackBar(
        SnackBar(
            content: Text(AppLocalization.of(context)
                .translate('profile.photo_upload_inactive'))),
      );
    }
  }

  void _editName() {
    final currentName = ref.read(profileProvider).profile?.name ?? '';
    _nameController.text = currentName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalization.of(context).translate('profile.edit_name')),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText:
                AppLocalization.of(context).translate('profile.enter_name'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalization.of(context).translate('common.cancel')),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final localization = AppLocalization.of(context);

              final newName = _nameController.text.trim();
              if (newName.isNotEmpty) {
                final success = await ref
                    .read(profileProvider.notifier)
                    .updateName(newName);
                if (success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content:
                          Text(localization.translate('profile.name_updated')),
                    ),
                  );
                }
              }
              navigator.pop();
            },
            child: Text(AppLocalization.of(context).translate('common.save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading && !state.hasProfile) {
      return const AppLoadingWidget.fullscreen();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        ref.read(profileProvider.notifier).currentUserPhoto,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 50,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _editProfilePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 50),
                  Text(
                    state.profile?.fullName ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: _editName,
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (state.isUpdating)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Workbook
        _buildSectionTitle(context, 'workbook.title'),
        _buildSettingsCard(
          context,
          children: [
            _buildSettingsTile(
              context,
              title: AppLocalization.of(context).translate('workbook.title'),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkbookListScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Packages
        _buildSectionTitle(context, 'packages.title'),
        _buildSettingsCard(
          context,
          children: [
            _buildSettingsTile(
              context,
              title: AppLocalization.of(context).translate('packages.title'),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PackagesScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Appearance
        _buildSectionTitle(context, 'profile.appearance'),
        _buildSettingsCard(
          context,
          children: [
            _buildSettingsTile(
              context,
              title: AppLocalization.of(context).translate('profile.dark_mode'),
              trailing: Consumer(
                builder: (context, ref, _) {
                  final theme = ref.watch(themeProvider);
                  return Switch(
                    value: theme == ThemeMode.dark,
                    onChanged: (value) =>
                        ref.read(themeProvider.notifier).toggleTheme(),
                  );
                },
              ),
            ),
            _buildSettingsTile(
              context,
              title: AppLocalization.of(context).translate('profile.language'),
              trailing: Consumer(
                builder: (context, ref, _) {
                  final locale = ref.watch(localeProvider);
                  final splashState = ref.watch(splashNotifierProvider);
                  final availableLanguages = splashState.data?.languages ?? [];

                  if (availableLanguages.isEmpty) {
                    return DropdownButton<String>(
                      value: locale.languageCode,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: 'tr',
                          child: Text(AppLocalization.of(context)
                              .translate('common.languages.turkish')),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(AppLocalization.of(context)
                              .translate('common.languages.english')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null)
                          ref.read(localeProvider.notifier).setLocale(value);
                      },
                    );
                  }

                  // Verify current locale is in the available languages list
                  final isValidLocale = availableLanguages
                      .any((lang) => lang.code == locale.languageCode);
                  final currentValue = isValidLocale
                      ? locale.languageCode
                      : availableLanguages.first.code;

                  return DropdownButton<String>(
                    value: currentValue,
                    underline: const SizedBox(),
                    items: availableLanguages.map((lang) {
                      return DropdownMenuItem(
                        value: lang.code,
                        child: Text(lang.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null)
                        ref.read(localeProvider.notifier).setLocale(value);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Logout Button
        ElevatedButton(
          onPressed: () => _handleLogout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            AppLocalization.of(context).translate('auth.logout'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalization.of(context).translate('auth.logout_title')),
        content: Text(
            AppLocalization.of(context).translate('auth.logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalization.of(context).translate('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalization.of(context).translate('auth.logout')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final navigator = Navigator.of(context);
      await ref.read(authProvider.notifier).signOut();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashView()),
        (route) => false,
      );
    }
  }

  Widget _buildSectionTitle(BuildContext context, String titleKey) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        AppLocalization.of(context).translate(titleKey),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required String title, Widget? trailing}) {
    return ListTile(
      title: Text(title),
      trailing: trailing,
    );
  }
}
