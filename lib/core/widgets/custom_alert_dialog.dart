import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Widget? icon;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: icon,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
      ),
      actions: [
        if (secondaryButtonText != null)
          TextButton(
            onPressed: onSecondaryPressed ?? () => Navigator.pop(context),
            child: Text(secondaryButtonText!),
          ),
        if (primaryButtonText != null)
          FilledButton(
            onPressed: onPrimaryPressed ?? () => Navigator.pop(context),
            child: Text(primaryButtonText!),
          ),
      ],
    );
  }
}
