import 'package:flutter/material.dart';
import 'translations.dart';

String translate(BuildContext context, String source) =>
    translateFor(Localizations.localeOf(context).languageCode, source);

/// Depends on Localizations so even const labels and retained routes update
/// immediately. Stored pet data, identities and business values stay unchanged.
class AppText extends StatelessWidget {
  const AppText(this.data,
      {super.key,
      this.style,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.softWrap,
      this.textDirection,
      this.semanticsLabel});
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextDirection? textDirection;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Text(translate(context, data),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      semanticsLabel:
          semanticsLabel == null ? null : translate(context, semanticsLabel!));
}
