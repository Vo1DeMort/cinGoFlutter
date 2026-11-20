class ShowtimeDay {
  const ShowtimeDay({
    required this.day,
    required this.weekday,
    required this.month,
    this.isToday = false,
  });

  final String day;
  final String weekday;
  final String month;
  final bool isToday;

  String get shortLabel => isToday ? 'TODAY' : weekday.toUpperCase();
}

class ShowtimeOption {
  const ShowtimeOption({
    required this.time,
    required this.status,
    this.available = true,
    this.soldOut = false,
  });

  final String time;
  final String status;
  final bool available;
  final bool soldOut;
}

class ShowtimeFormat {
  const ShowtimeFormat({
    required this.format,
    required this.description,
    required this.price,
    required this.times,
    this.isPremium = true,
  });

  final String format;
  final String description;
  final double price;
  final List<ShowtimeOption> times;
  final bool isPremium;
}

class CinemaListing {
  const CinemaListing({
    required this.name,
    required this.address,
    required this.distance,
    required this.amenities,
    required this.formats,
    this.badges = const [],
    this.rating,
  });

  final String name;
  final String address;
  final String distance;
  final List<String> amenities;
  final List<ShowtimeFormat> formats;
  final List<String> badges;
  final double? rating;
}

class SelectedShowtime {
  const SelectedShowtime({
    required this.cinema,
    required this.format,
    required this.time,
    required this.price,
    required this.day,
    required this.auditorium,
  });

  final String cinema;
  final String format;
  final String time;
  final double price;
  final String day;
  final String auditorium;

  String get summary => '$cinema • $day, $time';
}
