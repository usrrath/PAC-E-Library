class PdfNote {
  final String id;
  final int page;
  final String selectedText;
  final String comment;
  final String color;

  const PdfNote({
    required this.id,
    required this.page,
    required this.selectedText,
    required this.comment,
    required this.color,
  });

  factory PdfNote.fromJson(Map<String, dynamic> json) {
    return PdfNote(
      id: '${json['id'] ?? DateTime.now().millisecondsSinceEpoch}',
      page: int.tryParse('${json['page_number'] ?? json['page'] ?? 1}') ?? 1,
      selectedText: '${json['selected_text'] ?? ''}',
      comment: '${json['comment'] ?? ''}',
      color: '${json['highlight_color'] ?? '#FFF59D'}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page_number': page,
      'selected_text': selectedText,
      'comment': comment,
      'highlight_color': color,
    };
  }
}