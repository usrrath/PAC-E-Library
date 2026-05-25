// utils/search_utils.dart

dynamic extractData(dynamic json) {
  if (json is Map && json['data'] != null) {
    return json['data'];
  }

  return json;
}

String strValue(Map data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];

    if (value == null) {
      continue;
    }

    final text = value.toString().trim();

    if (text.isNotEmpty && text != 'null') {
      return text;
    }
  }

  return '';
}

int intValue(Map data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];

    if (value == null) {
      continue;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    final parsed = int.tryParse(value.toString().trim());

    if (parsed != null) {
      return parsed;
    }
  }

  return 0;
}

DateTime? parseDateValue(
    Map data,
    List<String> keys,
    ) {
  for (final key in keys) {
    final value = data[key];

    if (value == null) {
      continue;
    }

    final parsed = DateTime.tryParse(
      value.toString(),
    );

    if (parsed != null) {
      return parsed;
    }
  }

  return null;
}

List<String> tagsValue(
    Map<String, dynamic> json,
    ) {
  final value = json['tags'] ??
      json['book_tags'] ??
      json['tag'];

  if (value is List) {
    return value
        .map((e) {
      if (e is Map) {
        return strValue(
          e,
          const [
            'name',
            'title',
            'tag_name',
          ],
        );
      }

      return e.toString().trim();
    })
        .where(
          (e) =>
      e.isNotEmpty &&
          e != 'null',
    )
        .toSet()
        .toList();
  }

  if (value is String) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where(
          (e) =>
      e.isNotEmpty &&
          e != 'null',
    )
        .toSet()
        .toList();
  }

  return [];
}