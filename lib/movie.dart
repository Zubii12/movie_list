import 'package:flutter/cupertino.dart';

class Movie {
  Movie({
    @required this.id,
    @required this.title,
    @required this.year,
    @required this.rating,
    @required this.genres,
    @required this.mediumCover,
    @required this.largeCover,
    @required this.summary,
  });

  factory Movie.fromJson(dynamic item) {
    return Movie(
      id: item['id'],
      title: item['title'],
      year: item['year'],
      rating: item['rating'].toString(),
      genres: item['genres'],
      mediumCover: item['medium_cover_image'],
      largeCover: item['large_cover_image'],
      summary: item['summary'],
    );
  }

  final int id;
  final String title;
  final int year;
  final String rating;
  final List<dynamic> genres;
  final String mediumCover;
  final String largeCover;
  final String summary;
  @override
  String toString() {
    return 'Movie('
        ' id: $id,'
        ' title: $title,'
        ' year: $year,'
        ' rating: $rating,'
        ' genres: $genres,'
        ' mediumCover: $mediumCover,'
        ' largeCover: $largeCover,'
        ' summary: $summary';
  }
}
