import 'package:flutter/material.dart';

class BottomSheetListTileButton extends StatelessWidget {
  const BottomSheetListTileButton(
      {super.key,
      this.routePage,
      required this.title,
      this.icon,
      this.onPressed,
      this.textColor});
  final Widget? routePage;
  final VoidCallback? onPressed;
  final String title;
  final Color? textColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (onPressed != null) {
          onPressed?.call();
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => routePage ?? const SizedBox.shrink(),
          ),
        );
      },
      child: Column(
        children: [
          const Divider(),
          ListTile(
            contentPadding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            trailing: Icon(Icons.arrow_forward_ios,
                size: 20, color: Colors.grey.shade500),
            title: Container(
              margin: const EdgeInsets.only(top: 15, left: 10),
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            leading: SizedBox(
                height: MediaQuery.sizeOf(context).height, child: icon),
            dense: true,
          ),
        ],
      ),
    );
  }
}
