enum FontSizePref {
  small,
  medium,
  large,
}

class PickItem {
  final String label;
  final String value;

  const PickItem({
    required this.label,
    required this.value,
  });
}