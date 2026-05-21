import 'package:flutter/material.dart';

import '../models/pdf_note_model.dart';

class SelectionRects {
  final int page;
  final List<PdfRect> rects;

  const SelectionRects({
    required this.page,
    required this.rects,
  });
}

class PdfReaderUtils {
  const PdfReaderUtils._();

  static Color parseHexColor(String value) {
    var hex = value.trim().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.tryParse(hex, radix: 16) ?? 0xFFFFF59D);
  }

  static IconData iconForNote(PdfNote note) {
    switch (note.type.trim().toLowerCase()) {
      case 'underline':
        return Icons.format_underlined;
      case 'strikethrough':
        return Icons.format_strikethrough;
      case 'squiggly':
        return Icons.gesture;
      case 'comment':
        return Icons.note_alt_outlined;
      default:
        return note.comment.trim().isNotEmpty
            ? Icons.note_alt_outlined
            : Icons.border_color;
    }
  }
}
