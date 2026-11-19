import 'package:cinego/data/mock_data.dart';
import 'package:cinego/models/booking.dart';
import 'package:cinego/models/showtime.dart';

const testShowtime = SelectedShowtime(
  cinema: 'AMC Metreon 16 & IMAX',
  format: 'IMAX 70MM',
  time: '4:45 PM',
  price: 29.50,
  day: 'Today',
  auditorium: 'Auditorium 1',
);

Booking testBooking() => MockData.initialBookings(MockData.movies).first;
