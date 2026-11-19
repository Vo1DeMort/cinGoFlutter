class SnackSize {
  const SnackSize({required this.label, required this.price});

  final String label;
  final double price;
}

class SnackItem {
  const SnackItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.section,
    this.badge,
    this.isPopular = false,
    this.isChefPick = false,
    this.isVegetarian = false,
    this.isGlutenFree = false,
    this.sizes = const [],
    this.flavours = '',
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String section;
  final String? badge;
  final bool isPopular;
  final bool isChefPick;
  final bool isVegetarian;
  final bool isGlutenFree;
  final List<SnackSize> sizes;
  final String flavours;

  String get displayPrice => '\$${price.toStringAsFixed(2)}';
}
