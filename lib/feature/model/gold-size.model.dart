class CardSize {
  final String label;
  final double width;
  final double height;
  final String goldPlacement;

  const CardSize({
    required this.label,
    required this.width,
    required this.height,
    required this.goldPlacement,
  });

  /// Creates a [CardSize] instance from a map.
  factory CardSize.fromMap(Map<String, dynamic> map) {
    return CardSize(
      label: map['label'] as String,
      width: map['width'] as double,
      height: map['height'] as double,
      goldPlacement: map['goldPlacement'] as String,
    );
  }

  /// Converts this [CardSize] instance into a map.
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'width': width,
      'height': height,
      'goldPlacement': goldPlacement,
    };
  }
}
