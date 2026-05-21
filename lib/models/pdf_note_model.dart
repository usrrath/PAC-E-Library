import 'dart:convert';
import 'dart:math' as math;

class PdfRect {
  final double x;
  final double y;
  final double w;
  final double h;

  const PdfRect({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  factory PdfRect.fromJson(Map<String, dynamic> json) {
    double read(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        if (value is num) return value.toDouble();

        final parsed = double.tryParse(
          value.toString().trim().replaceAll('%', ''),
        );
        if (parsed != null) return parsed;
      }
      return 0.0;
    }

    return PdfRect(
      x: _normalize(read(const ['x', 'left'])),
      y: _normalize(read(const ['y', 'top'])),
      w: _normalize(read(const ['w', 'width'])),
      h: _normalize(read(const ['h', 'height'])),
    ).fixed();
  }

  static double _normalize(double value) {
    if (value.isNaN || value.isInfinite) return 0.0;
    if (value > 1.0 && value <= 100.0) return value / 100.0;
    return value;
  }

  PdfRect fixed() {
    final nx = x.clamp(0.0, 1.0).toDouble();
    final ny = y.clamp(0.0, 1.0).toDouble();
    final nw = w.clamp(0.0, 1.0 - nx).toDouble();
    final nh = h.clamp(0.0, 1.0 - ny).toDouble();

    return PdfRect(x: nx, y: ny, w: nw, h: nh);
  }

  Map<String, dynamic> toJson() {
    final r = fixed();
    return {
      'x': _round(r.x),
      'y': _round(r.y),
      'w': _round(r.w),
      'h': _round(r.h),
    };
  }

  static double _round(double value) => double.parse(value.toStringAsFixed(8));

  bool get isValid {
    return x >= 0 &&
        y >= 0 &&
        w > 0 &&
        h > 0 &&
        x < 1 &&
        y < 1 &&
        x + w <= 1.0001 &&
        y + h <= 1.0001;
  }
}

class PdfNote {
  final String id;
  final int itemId;
  final int page;
  final String selectedText;
  final String comment;
  final String color;
  final String type;
  final List<PdfRect> rects;

  const PdfNote({
    required this.id,
    required this.itemId,
    required this.page,
    required this.selectedText,
    required this.comment,
    required this.color,
    required this.type,
    required this.rects,
  });

  factory PdfNote.fromJson(Map<String, dynamic> json) {
    final comment = '${json['comment'] ?? ''}'.trim();
    final rawType = '${json['type'] ?? json['annotation_type'] ?? ''}'.trim();

    return PdfNote(
      id: '${json['id'] ?? DateTime.now().microsecondsSinceEpoch}',
      itemId: int.tryParse('${json['item_id'] ?? json['book_id'] ?? 0}') ?? 0,
      page: math.max(
        1,
        int.tryParse('${json['page'] ?? json['page_number'] ?? 1}') ?? 1,
      ),
      selectedText: '${json['selected_text'] ?? ''}'.trim(),
      comment: comment,
      color: _safeColor('${json['highlight_color'] ?? json['color'] ?? '#FFF59D'}'),
      type: _safeType(rawType, comment),
      rects: _parseRects(json['rects'] ?? json['rect_json'] ?? json['position_json']),
    );
  }

  static String _safeType(String type, String comment) {
    final t = type.toLowerCase().trim();
    switch (t) {
      case 'highlight':
      case 'comment':
      case 'underline':
      case 'strikethrough':
      case 'squiggly':
        return t;
      default:
        return comment.isNotEmpty ? 'comment' : 'highlight';
    }
  }

  static String _safeColor(String value) {
    final color = value.trim();
    if (color.startsWith('#') && (color.length == 7 || color.length == 9)) {
      return color.toUpperCase();
    }
    return '#FFF59D';
  }

  static List<PdfRect> _parseRects(dynamic value) {
    if (value == null) return const [];

    dynamic decoded = value;
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty || text == 'null') return const [];
      try {
        decoded = jsonDecode(text);
      } catch (_) {
        return const [];
      }
    }

    if (decoded is Map) decoded = [decoded];
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map((e) => PdfRect.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.isValid)
        .toList(growable: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'page': page,
      'page_number': page,
      'selected_text': selectedText,
      'comment': comment,
      'highlight_color': color,
      'type': type,
      'annotation_type': type,
      'rects': rects.map((e) => e.toJson()).toList(growable: false),
    };
  }

  bool get hasComment => comment.trim().isNotEmpty;
  bool get hasText => selectedText.trim().isNotEmpty;
  bool get hasRects => rects.isNotEmpty;
  bool get isEmpty => !hasComment && !hasText && !hasRects;
}
