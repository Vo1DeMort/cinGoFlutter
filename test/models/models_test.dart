import 'package:cinego/data/mock_data.dart';
import 'package:cinego/models/booking.dart';
import 'package:cinego/models/movie.dart';
import 'package:cinego/models/showtime.dart';
import 'package:cinego/models/snack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Movie', () {
    test('formats runtime with padded minutes', () {
      expect(MockData.dune.runtimeLabel, '2h 46m');
      const short = Movie(
        id: 'short',
        title: 'Short',
        synopsis: '',
        director: '',
        certificate: 'G',
        rating: 7,
        runtimeMinutes: 45,
        genres: ['Drama'],
        poster: '',
      );
      expect(short.runtimeLabel, '45m');
    });

    test('joins the first two genres', () {
      expect(MockData.dune.genreLabel, 'Sci-Fi • Adventure');
    });

    test('supports optional metadata defaults', () {
      const movie = Movie(
        id: 'plain',
        title: 'Plain',
        synopsis: '',
        director: '',
        certificate: 'G',
        rating: 1,
        runtimeMinutes: 60,
        genres: [],
        poster: '',
      );
      expect(movie.comingSoon, isFalse);
      expect(movie.cast, isEmpty);
      expect(movie.backdrop, isNull);
      expect(movie.releaseLabel, isNull);
      expect(movie.tagline, isNull);
      expect(movie.tomatoScore, isNull);
      expect(movie.genreLabel, '');
    });
  });

  group('Showtime models', () {
    test('ShowtimeDay exposes short labels', () {
      expect(MockData.showtimeDays.first.shortLabel, 'TODAY');
      expect(MockData.showtimeDays[1].shortLabel, 'FRI');
    });

    test('SelectedShowtime builds a summary', () {
      const selected = SelectedShowtime(
        cinema: 'AMC Metreon 16 & IMAX',
        format: 'IMAX 70MM',
        time: '4:45 PM',
        price: 24.50,
        day: 'Today',
        auditorium: 'Auditorium 1',
      );
      expect(selected.summary, 'AMC Metreon 16 & IMAX • Today, 4:45 PM');
    });

    test('showtime options default to available', () {
      const option = ShowtimeOption(time: '1:30 PM', status: 'Available');
      expect(option.available, isTrue);
    });

    test('cinema listings keep their metadata', () {
      final cinema = MockData.cinemas.first;
      expect(cinema.name, 'AMC Metreon 16 & IMAX');
      expect(cinema.badges, isNotEmpty);
      expect(cinema.formats, isNotEmpty);
    });
  });

  group('Booking', () {
    test('joins seats into a label', () {
      final booking = MockData.initialBookings(MockData.movies).first;
      expect(booking.seatLabel, 'E5, E6');
    });

    test('defaults are applied', () {
      const booking = Booking(
        id: 'b',
        code: '#CG-1',
        movie: MockData.dune,
        cinema: 'Cinema',
        auditorium: 'Screen 1',
        dateLabel: 'Today',
        time: '4:45 PM',
        seats: ['A1'],
        total: 10,
        poster: '',
        status: BookingStatus.upcoming,
      );
      expect(booking.format, 'IMAX 70MM');
      expect(booking.isVip, isTrue);
      expect(booking.hasPerk, isFalse);
      expect(booking.countdownLabel, isNull);
      expect(booking.gateLabel, isNull);
    });
  });

  group('Snack models', () {
    test('displayPrice formats currency', () {
      const snack = SnackItem(
        id: 's',
        name: 'Snack',
        description: '',
        price: 9.5,
        image: '',
        section: 'Combos',
      );
      expect(snack.displayPrice, '\$9.50');
    });

    test('optional flags default to false', () {
      const snack = SnackItem(
        id: 's',
        name: 'Snack',
        description: '',
        price: 1,
        image: '',
        section: 'Combos',
      );
      expect(snack.isPopular, isFalse);
      expect(snack.isChefPick, isFalse);
      expect(snack.isVegetarian, isFalse);
      expect(snack.isGlutenFree, isFalse);
      expect(snack.sizes, isEmpty);
      expect(snack.flavours, '');
    });

    test('sizes retain their price', () {
      const size = SnackSize(label: 'Large', price: 8.25);
      expect(size.label, 'Large');
      expect(size.price, 8.25);
    });
  });
}
