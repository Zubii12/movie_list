import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'movie.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({Key key, this.movie}) : super(key: key);

  final Movie movie;
  @override
  State<StatefulWidget> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.movie.title),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Center(
                child: Image.network(
                  widget.movie.largeCover,
                  fit: BoxFit.fill,
                  width: 400,
                  height: 450,
                  errorBuilder: (BuildContext context, Object error, StackTrace stackTrace) => const Icon(Icons.error),
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                            : null,
                      ),
                    );
                  },
                ),
              ),
              RatingBarIndicator(
                rating: double.tryParse(widget.movie.rating),
                itemBuilder: (BuildContext context, int index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                unratedColor: Colors.grey,
                itemCount: 10,
                itemSize: 25.0,
                direction: Axis.horizontal,
              ),
              Text(
                'Rating ' + widget.movie.rating,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 16.0),
              Row(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Year: ' + widget.movie.year.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Text(
                    'Genres' + widget.movie.genres.map<dynamic>((dynamic e) => e).toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.movie.summary,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
