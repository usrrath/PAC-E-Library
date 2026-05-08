import 'dart:convert';

/// =======================
/// PDF Read Progress Model
/// =======================

PdfReadProgressModel pdfReadProgressModelFromJson(String str) {
  return PdfReadProgressModel.fromJson(jsonDecode(str));
}

String pdfReadProgressModelToJson(PdfReadProgressModel data) {
  return jsonEncode(data.toJson());
}

class PdfReadProgressModel {
  final String? message;
  final List<PdfReadProgress> progress;

  PdfReadProgressModel({
    this.message,
    required this.progress,
  });

  factory PdfReadProgressModel.fromJson(Map<String, dynamic> json) {
    return PdfReadProgressModel(
      message: json['message']?.toString(),
      progress: json['progress'] == null
          ? []
          : List<PdfReadProgress>.from(
        (json['progress'] as List).map(
              (x) => PdfReadProgress.fromJson(x),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'progress': progress.map((x) => x.toJson()).toList(),
    };
  }
}

/// =======================
/// Single PDF Progress
/// =======================

class PdfReadProgress {
  final String id;

  final String userId;

  final String? itemId;

  final String? docKey;

  final int lastPage;

  final int totalPages;

  final double percent;

  final String? createdAt;

  final String? updatedAt;

  PdfReadProgress({
    required this.id,
    required this.userId,
    this.itemId,
    this.docKey,
    required this.lastPage,
    required this.totalPages,
    required this.percent,
    this.createdAt,
    this.updatedAt,
  });

  factory PdfReadProgress.fromJson(Map<String, dynamic> json) {
    return PdfReadProgress(
      id: json['id']?.toString() ?? '',

      userId: json['user_id']?.toString() ?? '',

      itemId: json['item_id']?.toString(),

      docKey: json['doc_key']?.toString(),

      lastPage: int.tryParse(
        json['last_page']?.toString() ?? '1',
      ) ??
          1,

      totalPages: int.tryParse(
        json['total_pages']?.toString() ?? '0',
      ) ??
          0,

      percent: double.tryParse(
        json['percent']?.toString() ?? '0',
      ) ??
          0.0,

      createdAt: json['created_at']?.toString(),

      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'user_id': userId,

      'item_id': itemId,

      'doc_key': docKey,

      'last_page': lastPage,

      'total_pages': totalPages,

      'percent': percent,

      'created_at': createdAt,

      'updated_at': updatedAt,
    };
  }

  /// =======================
  /// Helpers
  /// =======================

  bool get hasItem =>
      itemId != null && itemId!.isNotEmpty;

  bool get hasDocKey =>
      docKey != null && docKey!.isNotEmpty;

  bool get isCompleted => percent >= 100;

  double get progressValue {
    if (percent < 0) return 0;
    if (percent > 100) return 100;
    return percent;
  }

  String get progressText =>
      "${progressValue.toStringAsFixed(1)}%";
}