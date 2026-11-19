import 'movie.dart';

enum BookingStatus { upcoming, past, cancelled }

class Booking {
  const Booking({
    required this.id,
    required this.code,
    required this.movie,
    required this.cinema,
    required this.auditorium,
    required this.dateLabel,
    required this.time,
    required this.seats,
    required this.total,
    required this.poster,
    required this.status,
    this.format = 'IMAX 70MM',
    this.countdownLabel,
    this.gateLabel,
    this.isVip = true,
    this.hasPerk = false,
  });

  final String id;
  final String code;
  final Movie movie;
  final String cinema;
  final String auditorium;
  final String dateLabel;
  final String time;
  final List<String> seats;
  final double total;
  final String poster;
  final BookingStatus status;
  final String format;
  final String? countdownLabel;
  final String? gateLabel;
  final bool isVip;
  final bool hasPerk;

  String get seatLabel => seats.join(', ');
}
