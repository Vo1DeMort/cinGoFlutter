import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/mock_data.dart';
import '../models/booking.dart';
import '../models/movie.dart';
import '../models/snack.dart';

class AppState extends ChangeNotifier {
  AppState() : bookings = MockData.initialBookings(MockData.movies);

  int _tabIndex = 0;
  bool _loggedIn = true;
  bool _walletApplied = true;
  bool _sessionRemembered = true;
  bool _notificationsEnabled = true;
  bool _calendarSyncEnabled = true;
  bool _smsUpdatesEnabled = true;
  int? _lastCancelledBookingIndex;

  final Map<String, int> _cart = <String, int>{};
  final Map<String, SnackSize> _selectedSizes = <String, SnackSize>{};
  List<Booking> bookings;

  int get tabIndex => _tabIndex;
  bool get loggedIn => _loggedIn;
  bool get walletApplied => _walletApplied;
  bool get sessionRemembered => _sessionRemembered;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get calendarSyncEnabled => _calendarSyncEnabled;
  bool get smsUpdatesEnabled => _smsUpdatesEnabled;

  List<Booking> get upcomingBookings => bookings
      .where((booking) => booking.status == BookingStatus.upcoming)
      .toList();

  List<Booking> get pastBookings => bookings
      .where((booking) => booking.status == BookingStatus.past)
      .toList();

  Map<String, int> get cart => Map.unmodifiable(_cart);

  int get cartCount => _cart.values.fold(0, (sum, value) => sum + value);

  double get cartTotal {
    double total = 0;
    _cart.forEach((id, quantity) {
      final item = itemById(id);
      if (item == null) return;
      final size = _selectedSizes[id];
      final price = size?.price ?? item.price;
      total += price * quantity;
    });
    return total;
  }

  double get snacksSavings {
    if (_cart.isEmpty) return 0;
    return _cart.values.fold(0, (sum, value) => sum + value) * 1.0;
  }

  void selectTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }

  void signIn({bool remember = true}) {
    _loggedIn = true;
    _sessionRemembered = remember;
    notifyListeners();
  }

  void signOut() {
    _loggedIn = false;
    _tabIndex = 0;
    notifyListeners();
  }

  void setWalletApplied(bool value) {
    _walletApplied = value;
    notifyListeners();
  }

  void setRememberSession(bool value) {
    _sessionRemembered = value;
    notifyListeners();
  }

  void setNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setCalendarSync(bool value) {
    _calendarSyncEnabled = value;
    notifyListeners();
  }

  void setSmsUpdates(bool value) {
    _smsUpdatesEnabled = value;
    notifyListeners();
  }

  SnackItem? itemById(String id) {
    for (final item in MockData.snacks) {
      if (item.id == id) return item;
    }
    return null;
  }

  int quantityOf(String id) => _cart[id] ?? 0;

  SnackSize? sizeOf(String id) => _selectedSizes[id];

  void addSnack(SnackItem item, {SnackSize? size}) {
    _cart[item.id] = (_cart[item.id] ?? 0) + 1;
    if (size != null) {
      _selectedSizes[item.id] = size;
    }
    notifyListeners();
  }

  void removeSnack(SnackItem item) {
    final current = _cart[item.id] ?? 0;
    if (current <= 1) {
      _cart.remove(item.id);
      _selectedSizes.remove(item.id);
    } else {
      _cart[item.id] = current - 1;
    }
    notifyListeners();
  }

  void setSnackSize(SnackItem item, SnackSize size) {
    _selectedSizes[item.id] = size;
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _selectedSizes.clear();
    notifyListeners();
  }

  void addBooking(Booking booking) {
    bookings = [booking, ...bookings];
    notifyListeners();
  }

  void cancelBooking(Booking booking) {
    _lastCancelledBookingIndex = bookings.indexWhere((b) => b.id == booking.id);
    bookings = bookings
        .map(
          (b) => b.id == booking.id
              ? Booking(
                  id: b.id,
                  code: b.code,
                  movie: b.movie,
                  cinema: b.cinema,
                  auditorium: b.auditorium,
                  dateLabel: b.dateLabel,
                  time: b.time,
                  seats: b.seats,
                  total: b.total,
                  poster: b.poster,
                  status: BookingStatus.cancelled,
                  format: b.format,
                  isVip: b.isVip,
                )
              : b,
        )
        .toList();
    notifyListeners();
  }

  int? get lastCancelledBookingIndex => _lastCancelledBookingIndex;

  Booking bookingByCode(String code) {
    return bookings.firstWhere(
      (booking) => booking.code == code,
      orElse: () => bookings.first,
    );
  }

  Movie movieById(String id) => MockData.movies.firstWhere(
    (movie) => movie.id == id,
    orElse: () => MockData.dune,
  );
}

/// Riverpod source of truth for the user's session, cart and bookings.
final appStateProvider = ChangeNotifierProvider<AppState>((ref) => AppState());
