import 'package:cinego/data/mock_data.dart';
import 'package:cinego/models/booking.dart';
import 'package:cinego/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppState state;

  setUp(() => state = AppState());
  tearDown(() => state.dispose());

  test('starts on the home tab with seeded bookings', () {
    expect(state.tabIndex, 0);
    expect(state.loggedIn, isTrue);
    expect(state.walletApplied, isTrue);
    expect(state.sessionRemembered, isTrue);
    expect(state.notificationsEnabled, isTrue);
    expect(state.calendarSyncEnabled, isTrue);
    expect(state.smsUpdatesEnabled, isTrue);
    expect(state.upcomingBookings, hasLength(2));
    expect(state.pastBookings, hasLength(5));
    expect(state.cart, isEmpty);
    expect(state.cartCount, 0);
    expect(state.cartTotal, 0);
    expect(state.snacksSavings, 0);
  });

  test('selectTab updates once and notifies listeners', () {
    var notifications = 0;
    state.addListener(() => notifications++);

    state.selectTab(0);
    expect(notifications, 0);

    state.selectTab(2);
    expect(state.tabIndex, 2);
    expect(notifications, 1);
  });

  test('sign in and sign out update session flags', () {
    state.signOut();
    expect(state.loggedIn, isFalse);
    expect(state.tabIndex, 0);

    state.selectTab(3);
    state.signIn(remember: false);
    expect(state.loggedIn, isTrue);
    expect(state.sessionRemembered, isFalse);
  });

  test('preference setters notify and persist values', () {
    state.setWalletApplied(false);
    state.setRememberSession(false);
    state.setNotifications(false);
    state.setCalendarSync(false);
    state.setSmsUpdates(false);

    expect(state.walletApplied, isFalse);
    expect(state.sessionRemembered, isFalse);
    expect(state.notificationsEnabled, isFalse);
    expect(state.calendarSyncEnabled, isFalse);
    expect(state.smsUpdatesEnabled, isFalse);
  });

  group('snack cart', () {
    final combo = MockData.snacks.first;
    final popcorn = MockData.snacks.firstWhere(
      (s) => s.id == 'artisanal-popcorn',
    );

    test('adds items, quantities and custom sizes', () {
      state.addSnack(combo);
      state.addSnack(combo);
      expect(state.quantityOf(combo.id), 2);
      expect(state.cartCount, 2);
      expect(state.cartTotal, 45.00);
      expect(state.snacksSavings, 2);

      state.addSnack(popcorn, size: popcorn.sizes[2]);
      expect(state.quantityOf(popcorn.id), 1);
      expect(state.sizeOf(popcorn.id)?.label, 'Tub');
      expect(state.cartTotal, 45.00 + 13.50);
    });

    test('removes one item at a time and clears sizes', () {
      state.addSnack(combo);
      state.addSnack(combo);
      state.removeSnack(combo);
      expect(state.quantityOf(combo.id), 1);

      state.removeSnack(combo);
      expect(state.quantityOf(combo.id), 0);
      expect(state.sizeOf(combo.id), isNull);
    });

    test('size changes update the total', () {
      state.addSnack(popcorn);
      expect(state.cartTotal, 11.00);
      state.setSnackSize(popcorn, popcorn.sizes.first);
      expect(state.cartTotal, 9.50);
      expect(state.sizeOf(popcorn.id)?.label, 'Regular');
    });

    test('clearCart empties quantities and sizes', () {
      state.addSnack(combo);
      state.addSnack(popcorn, size: popcorn.sizes[1]);
      state.clearCart();
      expect(state.cart, isEmpty);
      expect(state.cartCount, 0);
      expect(state.cartTotal, 0);
      expect(state.sizeOf(popcorn.id), isNull);
    });

    test('lookup helpers return values and nulls', () {
      expect(state.itemById(combo.id), same(combo));
      expect(state.itemById('missing'), isNull);
      expect(state.quantityOf('missing'), 0);
      expect(state.sizeOf('missing'), isNull);
    });
  });

  group('bookings', () {
    test('addBooking prepends a reservation', () {
      final original = state.bookings.length;
      final booking = MockData.initialBookings(MockData.movies).first;
      state.addBooking(booking);
      expect(state.bookings, hasLength(original + 1));
      expect(state.bookings.first.id, booking.id);
      expect(state.upcomingBookings, hasLength(3));
    });

    test('cancelBooking marks a booking as cancelled and tracks its index', () {
      final booking = state.upcomingBookings.first;
      state.cancelBooking(booking);
      expect(state.lastCancelledBookingIndex, 0);
      expect(state.upcomingBookings, hasLength(1));
      expect(
        state.bookings.firstWhere((b) => b.id == booking.id).status,
        BookingStatus.cancelled,
      );
    });

    test('bookingByCode finds a match and falls back to the first booking', () {
      final first = state.bookings.first;
      expect(state.bookingByCode(first.code).id, first.id);
      expect(state.bookingByCode('missing').id, first.id);
    });

    test('movieById finds a movie and falls back to Dune', () {
      expect(state.movieById('oppenheimer').title, 'Oppenheimer');
      expect(state.movieById('missing'), same(MockData.dune));
    });
  });

  test('initialBookings seeds upcoming, past and optional metadata', () {
    final bookings = MockData.initialBookings(MockData.movies);
    expect(bookings, hasLength(7));
    expect(
      bookings.where((b) => b.status == BookingStatus.upcoming),
      hasLength(2),
    );
    expect(bookings.where((b) => b.status == BookingStatus.past), hasLength(5));
    expect(bookings.first.code, '#CG-89421-DX');
    expect(bookings.first.hasPerk, isTrue);
  });
}
