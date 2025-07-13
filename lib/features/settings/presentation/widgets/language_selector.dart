import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/localization/app_localization.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return ListTile(
      title: Text(AppLocalization.of(context).translate('common.language')),
      trailing: DropdownButton<String>(
        value: currentLocale.languageCode,
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
        onChanged: (String? languageCode) {
          if (languageCode != null) {
            ref.read(localeProvider.notifier).setLocale(languageCode);
          }
        },
      ),
    );
  }
}
