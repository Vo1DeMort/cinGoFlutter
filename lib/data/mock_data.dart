import '../models/booking.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../models/snack.dart';

/// Curated mock catalogue used across the CineGo experience.
abstract final class MockData {
  static const dune = Movie(
    id: 'dune-part-two',
    title: 'Dune: Part Two',
    synopsis:
        'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family. Facing a choice between the love of his life and the fate of the known universe, he endeavors to prevent a terrible future only he can foresee.',
    director: 'Denis Villeneuve',
    certificate: 'PG-13',
    rating: 9.4,
    runtimeMinutes: 166,
    genres: ['Sci-Fi', 'Adventure'],
    poster: 'assets/images/poster_dune_browse.jpg',
    backdrop: 'assets/images/backdrop_dune.jpg',
    tagline: 'Long live the fighters.',
    tomatoScore: 92,
    cast: [
      CastMember(
        name: 'Denis Villeneuve',
        role: 'Director',
        image: 'assets/images/cast_denis.jpg',
      ),
      CastMember(
        name: 'Timothée Chalamet',
        role: 'Paul Atreides',
        image: 'assets/images/cast_timothee.jpg',
      ),
      CastMember(
        name: 'Zendaya',
        role: 'Chani',
        image: 'assets/images/cast_rebecca.jpg',
      ),
      CastMember(
        name: 'Rebecca Ferguson',
        role: 'Lady Jessica',
        image: 'assets/images/cast_zendaya.jpg',
      ),
    ],
  );

  static const movies = <Movie>[
    dune,
    Movie(
      id: 'challengers',
      title: 'Challengers',
      synopsis:
          'Tashi, a tennis player turned coach, has taken her husband, Art, and transformed him into a world-famous grand slam champion. To jolt him out of his recent losing streak, she makes him play a challenger event.',
      director: 'Luca Guadagnino',
      certificate: 'R',
      rating: 7.8,
      runtimeMinutes: 131,
      genres: ['Drama', 'Sport'],
      poster: 'assets/images/poster_challengers.jpg',
      backdrop: 'assets/images/poster_challengers_browse.jpg',
      tomatoScore: 88,
      cast: [
        CastMember(
          name: 'Luca Guadagnino',
          role: 'Director',
          image: 'assets/images/cast_denis.jpg',
        ),
        CastMember(
          name: 'Zendaya',
          role: 'Tashi Duncan',
          image: 'assets/images/cast_rebecca.jpg',
        ),
        CastMember(
          name: 'Mike Faist',
          role: 'Art Donaldson',
          image: 'assets/images/cast_timothee.jpg',
        ),
      ],
    ),
    Movie(
      id: 'furiosa',
      title: 'Furiosa: A Mad Max Saga',
      synopsis:
          'Snatched from the Green Place of Many Mothers, young Furiosa falls into the hands of a great biker horde led by the warlord Dementus. Sweeping through the wasteland, they come upon the Citadel presided over by Immortan Joe.',
      director: 'George Miller',
      certificate: 'R',
      rating: 8.1,
      runtimeMinutes: 148,
      genres: ['Action', 'Sci-Fi'],
      poster: 'assets/images/poster_furiosa_home.jpg',
      backdrop: 'assets/images/poster_furiosa_browse.jpg',
      tomatoScore: 90,
      cast: [
        CastMember(
          name: 'George Miller',
          role: 'Director',
          image: 'assets/images/cast_denis.jpg',
        ),
        CastMember(
          name: 'Anya Taylor-Joy',
          role: 'Furiosa',
          image: 'assets/images/cast_zendaya.jpg',
        ),
        CastMember(
          name: 'Chris Hemsworth',
          role: 'Dementus',
          image: 'assets/images/cast_timothee.jpg',
        ),
      ],
    ),
    Movie(
      id: 'civil-war',
      title: 'Civil War',
      synopsis:
          'In a near-future America, a team of journalists travels across a country torn apart by a rapidly escalating civil war, racing toward Washington D.C. before rebel factions descend upon the White House.',
      director: 'Alex Garland',
      certificate: 'R',
      rating: 8.4,
      runtimeMinutes: 109,
      genres: ['Action', 'Drama'],
      poster: 'assets/images/poster_civilwar_home.jpg',
      backdrop: 'assets/images/poster_civilwar_browse.jpg',
      tomatoScore: 85,
      cast: [
        CastMember(
          name: 'Alex Garland',
          role: 'Director',
          image: 'assets/images/cast_denis.jpg',
        ),
        CastMember(
          name: 'Kirsten Dunst',
          role: 'Lee',
          image: 'assets/images/cast_zendaya.jpg',
        ),
        CastMember(
          name: 'Wagner Moura',
          role: 'Joel',
          image: 'assets/images/cast_timothee.jpg',
        ),
      ],
    ),
    Movie(
      id: 'gladiator-ii',
      title: 'Gladiator II',
      synopsis:
          'Years after witnessing the death of the revered hero Maximus at the hands of his uncle, Lucius is forced to enter the Colosseum after his home is conquered by the tyrannical emperors who now lead Rome with an iron fist.',
      director: 'Ridley Scott',
      certificate: 'R',
      rating: 8.2,
      runtimeMinutes: 148,
      genres: ['Historical Action', 'Drama'],
      poster: 'assets/images/poster_gladiator.jpg',
      comingSoon: true,
      releaseLabel: 'NOV 22',
      tomatoScore: 79,
      cast: [
        CastMember(
          name: 'Ridley Scott',
          role: 'Director',
          image: 'assets/images/cast_denis.jpg',
        ),
        CastMember(
          name: 'Paul Mescal',
          role: 'Lucius',
          image: 'assets/images/cast_timothee.jpg',
        ),
        CastMember(
          name: 'Denzel Washington',
          role: 'Macrinus',
          image: 'assets/images/cast_zendaya.jpg',
        ),
      ],
    ),
    Movie(
      id: 'joker-folie-a-deux',
      title: 'Joker: Folie à Deux',
      synopsis:
          'Struggling with his dual identity, failed comedian Arthur Fleck meets the love of his life, Harley Quinn, while incarcerated at Arkham State Hospital. Their shared delusion spirals into a musical romance.',
      director: 'Todd Phillips',
      certificate: 'R',
      rating: 7.6,
      runtimeMinutes: 138,
      genres: ['Musical Thriller', 'Drama'],
      poster: 'assets/images/poster_joker.jpg',
      comingSoon: true,
      releaseLabel: 'OCT 04',
      tomatoScore: 62,
      cast: [
        CastMember(
          name: 'Todd Phillips',
          role: 'Director',
          image: 'assets/images/cast_denis.jpg',
        ),
        CastMember(
          name: 'Joaquin Phoenix',
          role: 'Arthur Fleck',
          image: 'assets/images/cast_timothee.jpg',
        ),
        CastMember(
          name: 'Lady Gaga',
          role: 'Harley Quinn',
          image: 'assets/images/cast_zendaya.jpg',
        ),
      ],
    ),
    Movie(
      id: 'alien-romulus',
      title: 'Alien: Romulus',
      synopsis:
          'While scavenging the deep ends of a derelict space station, a group of young space colonizers come face to face with the most terrifying life form in the universe.',
      director: 'Fede Álvarez',
      certificate: 'R',
      rating: 7.9,
      runtimeMinutes: 119,
      genres: ['Horror', 'Sci-Fi'],
      poster: 'assets/images/poster_alien.jpg',
      tomatoScore: 80,
      cast: [],
    ),
    Movie(
      id: 'kingdom-of-the-planet-of-the-apes',
      title: 'Kingdom of the Planet of the Apes',
      synopsis:
          'Many years after the reign of Caesar, a young ape goes on a journey that will lead him to question everything he has been taught about the past and make choices that will define a future for apes and humans alike.',
      director: 'Wes Ball',
      certificate: 'PG-13',
      rating: 8.1,
      runtimeMinutes: 145,
      genres: ['Sci-Fi', 'Adventure'],
      poster: 'assets/images/poster_apes.jpg',
      tomatoScore: 82,
      cast: [],
    ),
    Movie(
      id: 'deadpool-and-wolverine',
      title: 'Deadpool & Wolverine',
      synopsis:
          'Wade Wilson is pulled from his quiet life and drafted into a mission that will change the history of the Marvel Cinematic Universe — alongside a reluctant Wolverine.',
      director: 'Shawn Levy',
      certificate: 'R',
      rating: 8.6,
      runtimeMinutes: 128,
      genres: ['Action', 'Comedy'],
      poster: 'assets/images/poster_deadpool.jpg',
      tomatoScore: 88,
      cast: [],
    ),
    Movie(
      id: 'a-quiet-place-day-one',
      title: 'A Quiet Place: Day One',
      synopsis:
          'A woman named Sam finds herself trapped in New York City during the early stages of an invasion by alien creatures with ultrasonic hearing.',
      director: 'Michael Sarnoski',
      certificate: 'PG-13',
      rating: 7.4,
      runtimeMinutes: 100,
      genres: ['Horror', 'Thriller'],
      poster: 'assets/images/poster_quietplace.jpg',
      tomatoScore: 72,
      cast: [],
    ),
    Movie(
      id: 'oppenheimer',
      title: 'Oppenheimer',
      synopsis:
          'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb, told across the vivid moral landscape of the twentieth century.',
      director: 'Christopher Nolan',
      certificate: 'R',
      rating: 9.0,
      runtimeMinutes: 181,
      genres: ['Biography', 'Drama'],
      poster: 'assets/images/poster_oppenheimer.jpg',
      tomatoScore: 94,
      cast: [],
    ),
  ];

  static List<Movie> get nowShowing =>
      movies.where((movie) => !movie.comingSoon).toList();

  static List<Movie> get comingSoon =>
      movies.where((movie) => movie.comingSoon).toList();

  static const homeShowtimes = <CinemaListing>[
    CinemaListing(
      name: 'AMC Metreon 16 & IMAX',
      address: '135 4th St, San Francisco',
      distance: '0.8 mi away',
      amenities: ['Luxury Recliners', 'Reserved Seating', 'Food & Seats'],
      badges: ['IMAX 70MM', 'Laser Projection', '12-Ch Sound'],
      formats: [
        ShowtimeFormat(
          format: 'IMAX 70MM',
          description: 'Laser Projection • 12-Ch Sound',
          price: 24.50,
          times: [
            ShowtimeOption(time: '1:30 PM', status: 'Available'),
            ShowtimeOption(time: '4:45 PM', status: 'Filling Fast'),
            ShowtimeOption(time: '8:15 PM', status: 'Almost Full'),
            ShowtimeOption(time: '11:30 PM', status: 'Available'),
          ],
        ),
        ShowtimeFormat(
          format: 'DOLBY CINEMA',
          description: 'Dolby Vision & Atmos',
          price: 22.00,
          times: [
            ShowtimeOption(time: '2:15 PM', status: 'Available'),
            ShowtimeOption(time: '6:30 PM', status: 'Filling Fast'),
            ShowtimeOption(time: '9:30 PM', status: 'Available'),
          ],
        ),
      ],
    ),
    CinemaListing(
      name: 'Alamo Drafthouse Cinema',
      address: '2550 Mission St, San Francisco',
      distance: '1.4 mi away',
      amenities: ['Dine-In Cinema', '4K Laser'],
      badges: ['4K LASER', 'Curated Preshow', 'Full Menu'],
      formats: [
        ShowtimeFormat(
          format: '4K LASER',
          description: 'Curated Preshow • Full Menu',
          price: 19.75,
          times: [
            ShowtimeOption(time: '3:00 PM', status: 'Available'),
            ShowtimeOption(time: '6:30 PM', status: 'Few Left'),
            ShowtimeOption(time: '10:00 PM', status: 'Available'),
          ],
        ),
      ],
    ),
  ];

  static const showtimeDays = <ShowtimeDay>[
    ShowtimeDay(day: '24', weekday: 'THU', month: 'OCT', isToday: true),
    ShowtimeDay(day: '25', weekday: 'FRI', month: 'OCT'),
    ShowtimeDay(day: '26', weekday: 'SAT', month: 'OCT'),
    ShowtimeDay(day: '27', weekday: 'SUN', month: 'OCT'),
    ShowtimeDay(day: '28', weekday: 'MON', month: 'OCT'),
    ShowtimeDay(day: '29', weekday: 'TUE', month: 'OCT'),
  ];

  static const snacks = <SnackItem>[
    SnackItem(
      id: 'dune-combo',
      name: "Dune: Part Two Collector's Combo",
      description: '1x Large Truffle Popcorn in commemorative tin, 2x Large Drinks',
      price: 22.50,
      image: 'assets/images/snack_dune_combo.jpg',
      section: 'Auditorium Exclusives',
      isPopular: true,
      badge: 'IMAX SPECIALS',
      flavours: 'Diet Coke, Ginger Ale, Truffle Butter',
    ),
    SnackItem(
      id: 'lounge-platter',
      name: 'VIP Cinema Lounge Platter',
      description: 'Wagyu beef sliders (2x), seasoned waffle fries, truffle aioli',
      price: 26.00,
      image: 'assets/images/snack_lounge_platter.jpg',
      section: 'Auditorium Exclusives',
      isChefPick: true,
    ),
    SnackItem(
      id: 'artisanal-popcorn',
      name: 'Warm Artisanal Popcorn',
      description: 'Butter • White Cheddar • Caramel',
      price: 11.00,
      image: 'assets/images/snack_popcorn.jpg',
      section: 'Popcorn & Classic Snacks',
      isVegetarian: true,
      flavours: 'Smoked White Cheddar • Extra butter layered',
      sizes: [
        SnackSize(label: 'Regular', price: 9.50),
        SnackSize(label: 'Large', price: 11.00),
        SnackSize(label: 'Tub', price: 13.50),
      ],
    ),
    SnackItem(
      id: 'gourmet-nachos',
      name: 'Gourmet Loaded Nachos',
      description: 'Warm queso blanco, jalapeños & guacamole',
      price: 12.50,
      image: 'assets/images/snack_nachos.jpg',
      section: 'Popcorn & Classic Snacks',
      isGlutenFree: true,
    ),
    SnackItem(
      id: 'pretzels',
      name: 'Artisan Pretzels & Beer Cheese',
      description: 'Warm Bavarian twists & craft dip',
      price: 11.00,
      image: 'assets/images/snack_pretzels.jpg',
      section: 'Popcorn & Classic Snacks',
    ),
    SnackItem(
      id: 'golden-gate-ipa',
      name: 'Golden Gate IPA (Draft)',
      description: 'Citrus hops, local San Francisco craft brew, 21+',
      price: 12.00,
      image: 'assets/images/snack_beer.jpg',
      section: 'Craft Drinks & Refreshments',
      badge: '6.8% ABV',
    ),
    SnackItem(
      id: 'obsidian-espresso',
      name: 'Obsidian Espresso Martini',
      description: 'Cold brew, premium vodka, coffee liqueur, 21+',
      price: 15.00,
      image: 'assets/images/snack_espresso.jpg',
      section: 'Craft Drinks & Refreshments',
      badge: 'SIGNATURE',
    ),
    SnackItem(
      id: 'fountain-soda',
      name: 'Freestyle Fountain Soda',
      description: '100+ flavors • Free refills at kiosk',
      price: 7.25,
      image: 'assets/images/snack_soda.jpg',
      section: 'Craft Drinks & Refreshments',
    ),
  ];

  static const snackSections = <String>[
    'Auditorium Exclusives',
    'Popcorn & Classic Snacks',
    'Craft Drinks & Refreshments',
  ];

  static List<CinemaListing> get cinemas => <CinemaListing>[
    homeShowtimes[0],
    const CinemaListing(
      name: 'Regal Stonestown & ScreenX',
      address: '501 Buckingham Way, San Francisco',
      distance: '3.4 mi away',
      amenities: ['Free garage parking', 'Reserved seating'],
      badges: ['SCREENX 270°', '4DX MOTION', 'KING SIZE RECLINERS'],
      formats: [],
      rating: 4.2,
    ),
    const CinemaListing(
      name: 'Century San Francisco Centre 9',
      address: '845 Market St, San Francisco',
      distance: '1.8 mi away',
      amenities: ['Direct concourse access', 'Bar access'],
      badges: ['CINEMARK XD', '4DX MOTION', 'BAR ACCESSIBLE'],
      formats: [],
      rating: 4.0,
    ),
  ];

  static const snackCategories = [
    'Combos',
    'Gourmet Popcorn',
    'Craft Drinks',
  ];

  static List<Booking> initialBookings(List<Movie> movies) {
    final byId = {for (final movie in movies) movie.id: movie};
    return [
      Booking(
        id: 'booking-dune',
        code: '#CG-89421-DX',
        movie: byId['dune-part-two']!,
        cinema: 'AMC Metreon 16 & IMAX',
        auditorium: 'Auditorium 1 • Screen 1',
        dateLabel: 'Today • 4:45 PM',
        time: '4:45 PM',
        seats: const ['E5', 'E6'],
        total: 96.10,
        poster: 'assets/images/poster_dune_bookings.jpg',
        status: BookingStatus.upcoming,
        countdownLabel: 'STARTS IN 2H 15M',
        gateLabel: 'Gate 4:25 PM',
        hasPerk: true,
      ),
      Booking(
        id: 'booking-gladiator',
        code: '#CG-90318-LR',
        movie: byId['gladiator-ii']!,
        cinema: 'Alamo Drafthouse',
        auditorium: 'Theater 4',
        dateLabel: 'Fri, Nov 22',
        time: '7:15 PM',
        seats: const ['D8', 'D9'],
        total: 42.50,
        poster: 'assets/images/poster_gladiator_bookings.jpg',
        status: BookingStatus.upcoming,
        countdownLabel: 'In 4 Days',
        format: 'DOLBY CINEMA',
        isVip: false,
      ),
      Booking(
        id: 'booking-furiosa',
        code: '#CG-77120-FR',
        movie: byId['furiosa']!,
        cinema: 'AMC Metreon 16 & IMAX',
        auditorium: 'Auditorium 3',
        dateLabel: 'Sat, Sep 14',
        time: '8:30 PM',
        seats: const ['C4', 'C5'],
        total: 55.00,
        poster: 'assets/images/poster_furiosa_bookings.jpg',
        status: BookingStatus.past,
        format: 'IMAX',
      ),
      Booking(
        id: 'booking-challengers',
        code: '#CG-65019-CH',
        movie: byId['challengers']!,
        cinema: 'Alamo Drafthouse',
        auditorium: 'Theater 2',
        dateLabel: 'Sun, Aug 25',
        time: '6:00 PM',
        seats: const ['A6'],
        total: 22.75,
        poster: 'assets/images/poster_challengers_bookings.jpg',
        status: BookingStatus.past,
        format: '35MM',
        isVip: false,
      ),
      Booking(
        id: 'booking-deadpool',
        code: '#CG-48810-DP',
        movie: byId['deadpool-and-wolverine']!,
        cinema: 'Century San Francisco Centre 9',
        auditorium: 'ScreenX 4',
        dateLabel: 'Thu, Aug 1',
        time: '7:45 PM',
        seats: const ['H6', 'H7'],
        total: 44.50,
        poster: 'assets/images/poster_deadpool.jpg',
        status: BookingStatus.past,
        format: 'SCREENX',
        isVip: false,
      ),
      Booking(
        id: 'booking-oppenheimer',
        code: '#CG-39217-OP',
        movie: byId['oppenheimer']!,
        cinema: 'AMC Metreon 16 & IMAX',
        auditorium: 'Auditorium 1',
        dateLabel: 'Sat, Jun 22',
        time: '8:10 PM',
        seats: const ['F5', 'F6'],
        total: 59.00,
        poster: 'assets/images/poster_oppenheimer.jpg',
        status: BookingStatus.past,
        format: 'IMAX 70MM',
      ),
      Booking(
        id: 'booking-civil-war',
        code: '#CG-51208-CW',
        movie: byId['civil-war']!,
        cinema: 'Regal Stonestown',
        auditorium: 'Theater 7',
        dateLabel: 'Fri, Jul 12',
        time: '9:10 PM',
        seats: const ['F7', 'F8'],
        total: 38.00,
        poster: 'assets/images/poster_civilwar_bookings.jpg',
        status: BookingStatus.past,
        format: 'DOLBY',
        isVip: false,
      ),
    ];
  }
}
