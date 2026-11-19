class CastMember {
  const CastMember({
    required this.name,
    required this.role,
    required this.image,
  });

  final String name;
  final String role;
  final String image;
}

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.director,
    required this.certificate,
    required this.rating,
    required this.runtimeMinutes,
    required this.genres,
    required this.poster,
    this.backdrop,
    this.comingSoon = false,
    this.releaseLabel,
    this.tagline,
    this.cast = const [],
    this.tomatoScore,
  });

  final String id;
  final String title;
  final String synopsis;
  final String director;
  final String certificate;
  final double rating;
  final int runtimeMinutes;
  final List<String> genres;
  final String poster;
  final String? backdrop;
  final bool comingSoon;
  final String? releaseLabel;
  final String? tagline;
  final List<CastMember> cast;
  final int? tomatoScore;

  String get runtimeLabel {
    final hours = runtimeMinutes ~/ 60;
    final minutes = runtimeMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  String get genreLabel => genres.take(2).join(' • ');
}
