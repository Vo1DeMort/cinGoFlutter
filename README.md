# CineGo

A premium movie discovery and ticket-booking experience built with Flutter.

CineGo pairs an "Obsidian Cinema" dark theme with a five-tab flow: discover
movies, browse cinemas and showtimes, manage bookings, order concessions, and
handle a CinePass Gold member profile. All data is local mock data, so the app
runs without a backend.

## Features

- Movie discovery, details, showtimes, and seat selection with a live hold timer
- Checkout with wallet credit, promo codes, and snack pre-orders
- Booking management, QR tickets, and cancellation flows
- Error and recovery surfaces: offline cache, payment hold timeout, seat
  collision quick fixes, and sold-out showtime waitlists

## Getting started

```sh
flutter pub get
flutter run
```

The project targets Flutter 3.50 / Dart 3.14 and uses Riverpod for app state.

## Tests

```sh
flutter test
flutter analyze
```

The widget suite covers every screen, Riverpod state transitions, and the
error/recovery navigation paths.

## Platform notes

Linux desktop scaffolding is included in `linux/`. Android, iOS, macOS, web,
and Windows runners can be generated with `flutter create .`.
