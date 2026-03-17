import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/app_loading_widget.dart';
import '../notifier/gdpr_notifier.dart';

class GDPRView extends ConsumerWidget {
  const GDPRView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gdprState = ref.watch(gdprProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(gdprState.value?.title ?? ''),
      ),
      body: gdprState.when(
        loading: () => const AppLoadingWidget.fullscreen(),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (gdpr) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image/Icon Section
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.privacy_tip_rounded,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title Section
              Text(
                gdpr.h1,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildText(gdpr.p1),
              const SizedBox(height: 8),
              _buildText(gdpr.p1Suffix, isItalic: true),
              const SizedBox(height: 16),
              _buildText(gdpr.p2),
              const SizedBox(height: 32),

              // Why Section
              _buildSectionHeader(context, gdpr.h2),
              _buildModernCard(
                context,
                child: Column(
                  children: [
                    _buildText(gdpr.p3),
                    const SizedBox(height: 12),
                    _buildText(gdpr.p4),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Data List Section
              _buildSectionHeader(context, gdpr.h3),
              _buildModernCard(
                context,
                child: Column(
                  children: gdpr.listItems.map((item) => _buildListItem(context, item)).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // Storage Duration Section
              _buildSectionHeader(context, gdpr.h4),
              _buildText(gdpr.p5),
              const SizedBox(height: 32),

              // Rights Section
              _buildSectionHeader(context, gdpr.h5),
              _buildText(gdpr.p6),
              const SizedBox(height: 32),

              // Contact Section
              _buildSectionHeader(context, gdpr.contactTitle),
              _buildModernCard(
                context,
                color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildText(gdpr.contactP1),
                    const SizedBox(height: 16),
                    _buildContactRow(context, Icons.business_rounded, gdpr.contactCompany),
                    _buildContactRow(context, Icons.info_outline_rounded, '${gdpr.contactOrgNo} ...'),
                    _buildContactRow(context, Icons.phone_rounded, gdpr.contactPhone),
                    _buildContactRow(context, Icons.email_rounded, gdpr.contactEmail),
                    const SizedBox(height: 16),
                    Text(
                      gdpr.contactAddressTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _buildText(gdpr.contactAddress.replaceAll('<br>', '\n')),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: gdpr.contactEmail,
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
                        icon: const Icon(Icons.send_rounded),
                        label: Text(gdpr.contactBtn),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Footer with Link
              Center(
                child: Text(
                  gdpr.footer.replaceAll(RegExp(r'<[^>]*>'), ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse('https://www.datainspektionen.se'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('www.datainspektionen.se'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
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
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: child,
    );
  }

  Widget _buildText(String text, {bool isItalic = false}) {
    // Basic HTML tag removal for strong tags etc.
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, 
               color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: _buildText(text)),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
