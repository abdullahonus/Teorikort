import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/app_loading_widget.dart';
import '../notifier/policy_notifier.dart';

class PolicyView extends ConsumerWidget {
  const PolicyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policyState = ref.watch(policyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(policyState.value?.title ?? ''),
      ),
      body: policyState.when(
        loading: () => const AppLoadingWidget.fullscreen(),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (policy) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.secondary, colorScheme.secondaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy.subtitle,
                      style: TextStyle(
                        color: colorScheme.onSecondary.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      policy.title,
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildText(policy.p1),
              const SizedBox(height: 8),
              _buildText(policy.p1Suffix, isItalic: true),
              const SizedBox(height: 32),

              // Sections
              _buildSection(context, policy.h1, policy.desc1),
              _buildSection(context, policy.h2, policy.desc2),
              _buildSection(context, policy.h3, policy.desc3),
              
              // Refund Policy with List
              _buildSectionHeader(context, policy.h4),
              _buildModernCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildText(policy.desc4),
                    Text(policy.desc4Suffix, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...policy.listItems.map((item) => _buildListItem(context, item)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSection(context, policy.h5, policy.desc5),

              // Contact Section
              _buildSectionHeader(context, policy.contactTitle),
              _buildModernCard(
                context,
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactRow(context, Icons.info_outline, '${policy.contactOrgNo} ...'),
                    _buildContactRow(context, Icons.phone, policy.contactPhone),
                    _buildContactRow(context, Icons.language, policy.contactWeb),
                    const SizedBox(height: 16),
                    Text(
                      policy.contactAddressTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _buildText(policy.contactAddress.replaceAll('<br>', '\n')),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'info@jarfallatrafikskola.se',
                          );
                          if (await canLaunchUrl(emailLaunchUri)) {
                            await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('E-posta uygulaması bulunamadı')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.mail_outline),
                        label: Text(policy.contactBtn),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, title),
        _buildText(content),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildModernCard(BuildContext context, {required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: child,
    );
  }

  Widget _buildText(String text, {bool isItalic = false}) {
    final cleanText = text.replaceAll('<strong>', '').replaceAll('</strong>', '');
    return Text(
      cleanText,
      style: TextStyle(
        height: 1.6,
        fontSize: 15,
        fontStyle: isItalic ? FontStyle.italic : null,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary,).paddingOnly(top: 8),
          const SizedBox(width: 12),
          Expanded(child: _buildText(text)),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

extension on Widget {
  Widget paddingOnly({double top = 0}) => Padding(padding: EdgeInsets.only(top: top), child: this);
}
