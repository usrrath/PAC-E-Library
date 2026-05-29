bool invalidCategory(String value) {
  final text =
  value.trim().toLowerCase();

  return text.isEmpty ||
      text == 'general' ||
      text == 'unknown';
}