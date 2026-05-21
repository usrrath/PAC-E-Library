import 'package:flutter/material.dart';

import '../models/pdf_note_model.dart';

class PdfMarkupPainter extends CustomPainter {
  final List<PdfNote> notes;
  final Map<int, Rect> pageBoxes;
  final Rect viewport;
  final Color Function(String value) parseColor;

  const PdfMarkupPainter({
    required this.notes,
    required this.pageBoxes,
    required this.viewport,
    required this.parseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final note in notes) {
      final pageBox = pageBoxes[note.page];
      if (pageBox == null || pageBox.isEmpty) continue;

      final type = note.type.trim().toLowerCase();
      final color = parseColor(note.color);
      final hasComment = note.comment.trim().isNotEmpty || type == 'comment';

      for (final rect in note.rects) {
        if (!rect.isValid) continue;

        final drawRect = Rect.fromLTWH(
          pageBox.left + rect.x * pageBox.width,
          pageBox.top + rect.y * pageBox.height,
          rect.w * pageBox.width,
          rect.h * pageBox.height,
        );

        if (drawRect.width <= 0 || drawRect.height <= 0) continue;
        if (!drawRect.overlaps(viewport)) continue;

        switch (type) {
          case 'underline':
            _paintLine(canvas, drawRect, color, drawRect.bottom - 2.5, 2.5);
            break;
          case 'strikethrough':
            _paintLine(canvas, drawRect, color, drawRect.center.dy, 2.2);
            break;
          case 'squiggly':
            _paintSquiggly(canvas, drawRect, color);
            break;
          case 'comment':
          case 'highlight':
          default:
            _paintHighlight(canvas, drawRect, color, hasComment);
            break;
        }
      }
    }
  }

  void _paintHighlight(Canvas canvas, Rect rect, Color color, bool hasComment) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
    final paint = Paint()
      ..color = color.withOpacity(hasComment ? 0.30 : 0.42)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, paint);

    if (hasComment) {
      final border = Paint()
        ..color = color.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(rrect, border);

      final iconPaint = Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(rect.right - 5, rect.top + 5), 3, iconPaint);
    }
  }

  void _paintLine(Canvas canvas, Rect rect, Color color, double y, double strokeWidth) {
    final paint = Paint()
      ..color = color.withOpacity(0.95)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
  }

  void _paintSquiggly(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.95)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const waveWidth = 8.0;
    final midY = rect.bottom - 4;
    final path = Path()..moveTo(rect.left, midY);

    for (double x = rect.left; x < rect.right; x += waveWidth) {
      path.quadraticBezierTo(x + waveWidth / 4, midY - 3, x + waveWidth / 2, midY);
      path.quadraticBezierTo(x + waveWidth * 3 / 4, midY + 3, x + waveWidth, midY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PdfMarkupPainter oldDelegate) {
    return oldDelegate.notes != notes ||
        oldDelegate.pageBoxes != pageBoxes ||
        oldDelegate.viewport != viewport;
  }
}
