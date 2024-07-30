import 'package:flutter/material.dart';

class TextWithResultMatch extends StatelessWidget {
  final String text;
  final String? searchQuery;
  final TextStyle style;
  const TextWithResultMatch({super.key, required this.text, this.searchQuery, required this.style});

  @override
  Widget build(BuildContext context) {
    if (searchQuery == null) {
      return RichText(
          text: TextSpan(children: [
            TextSpan(text: text, style: style)
          ])
      );
    }
    final textSlices = text.split(searchQuery!);
    final textSpans = <TextSpan>[];
    for (var i = 0; i < textSlices.length; i++) {
      final slice = textSlices[i];
      textSpans.add(TextSpan(text: slice, style: style));
      if (i < textSlices.length - 1) {
        textSpans.add(TextSpan(
            text: searchQuery,
            style: style.copyWith(fontWeight: FontWeight.bold)));
      }
    }
    return RichText(text: TextSpan(children: textSpans));
  }
}
