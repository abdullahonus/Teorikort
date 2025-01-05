import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:driving_license_exam/core/providers/locale_provider.dart';
import 'package:driving_license_exam/core/providers/theme_provider.dart';
import 'package:driving_license_exam/features/profile/presentation/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:driving_license_exam/core/services/user_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeUserService();
  }

  Future<void> _initializeUserService() async {
    await _userService.initializeService();
    if (mounted) {
      setState(() {
        _nameController.text = _userService.currentUserName;
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editProfilePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Gerçek bir uygulamada, burada fotoğrafı bir sunucuya yükleyip URL'sini alırdık
      // Şimdilik örnek bir URL kullanacağız
      final randomNumber = DateTime.now().millisecondsSinceEpoch % 20 + 1;
      final newPhotoUrl =
          'https://xsgames.co/randomusers/assets/avatars/male/$randomNumber.jpg';

      setState(() {
        _userService.updateUserPhoto(newPhotoUrl);
      });
    }
  }

  void _editName() {
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
              if (_nameController.text.trim().isNotEmpty) {
                await _userService.updateUserName(_nameController.text.trim());
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalization.of(context)
                            .translate('profile.name_updated'),
                      ),
                    ),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: Text(AppLocalization.of(context).translate('common.save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Kullanıcı Profil Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
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
                        color: colorScheme.primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        _userService.currentUserPhoto,
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
                  Text(
                    _userService.currentUserName,
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
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Görünüm Ayarları
        _buildSectionTitle(context, 'profile.appearance'),
        _buildSettingsCard(
          context,
          children: [
            Consumer(
              builder: (context, ref, child) {
                final isDark = ref.watch(themeProvider);
                return _buildSettingsTile(
                  context,
                  title: AppLocalization.of(context)
                      .translate('profile.dark_mode'),
                  trailing: Switch(
                    value: isDark == ThemeMode.dark,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                );
              },
            ),
            _buildSettingsTile(
              context,
              title: AppLocalization.of(context).translate('profile.language'),
              trailing: Consumer(
                builder: (context, ref, child) {
                  final currentLocale = ref.watch(localeProvider);
                  return DropdownButton<String>(
                    value: currentLocale.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'tr',
                        child: Text('Türkçe'),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(localeProvider.notifier).setLocale(value);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Veri ve Depolama
        _buildSectionTitle(context, 'profile.data_storage'),
        _buildSettingsCard(
          context,
          children: [
            _buildSettingsTile(
              context,
              title:
                  AppLocalization.of(context).translate('profile.clear_data'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearDataDialog(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Uygulama Bilgileri
        _buildSectionTitle(context, 'profile.app'),
        _buildSettingsCard(
          context,
          children: [
            _buildSettingsTile(
              context,
              title: AppLocalization.of(context).translate('profile.share_app'),
              trailing: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareApp(context),
              ),
            ),
            _buildSettingsTile(
              context,
              title: AppLocalization.of(context).translate('profile.rate_app'),
              trailing: IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: () => _rateApp(),
              ),
            ),
            _buildSettingsTile(
              context,
              title: AppLocalization.of(context).translate('profile.about'),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    Widget? trailing,
  }) {
    return ListTile(
      title: Text(title),
      trailing: trailing,
    );
  }

  Future<void> _shareApp(BuildContext context) async {
    final message =
        AppLocalization.of(context).translate('profile.share_message');
    await Share.share(message);
  }

  Future<void> _rateApp() async {
    final url =
        Uri.parse('https://play.google.com/store/apps/details?id=com.yourapp');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(AppLocalization.of(context).translate('profile.clear_data')),
        content: Text(
          AppLocalization.of(context)
              .translate('profile.clear_data_confirmation'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalization.of(context).translate('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalization.of(context).translate('common.clear')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalization.of(context).translate('profile.data_cleared'),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalization.of(context)
                    .translate('profile.data_clear_error'),
              ),
            ),
          );
        }
      }
    }
  }
}
