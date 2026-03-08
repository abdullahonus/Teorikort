import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:teorikort/core/utils/regex_patterns.dart';

class AppHtmlText extends StatelessWidget {
  final String htmlData;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppHtmlText({
    super.key,
    required this.htmlData,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // If it doesn't contain HTML tags, just render normal Text for performance
    if (!RegexPatterns.htmlTags.hasMatch(htmlData)) {
      return Text(
        htmlData,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return Html(
      data: htmlData,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(style?.fontSize ?? 14.0),
          color: style?.color ?? Theme.of(context).colorScheme.onSurface,
          fontWeight: style?.fontWeight,
          textAlign: _getHtmlTextAlign(textAlign),
          maxLines: maxLines,
          textOverflow: overflow,
        ),
      },
    );
  }

  TextAlign? _getHtmlTextAlign(TextAlign? align) {
    if (align == TextAlign.center) return TextAlign.center;
    if (align == TextAlign.right) return TextAlign.right;
    if (align == TextAlign.justify) return TextAlign.justify;
    return TextAlign.left;
  }
}
