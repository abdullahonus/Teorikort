import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static void showAlertDialog({
    required String title,
    required String message,
    Map<String, dynamic>? details,
    VoidCallback? onConfirm,
    String? buttonText,
    bool barrierDismissible = true,
  }) {
    final ctx = context;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(message),
              if (details != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Details:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...details.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('${e.key}: ${e.value}'),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            child: Text(buttonText ?? 'Tamam'),
          ),
        ],
      ),
    );
  }
}
