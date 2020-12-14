import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:movie_list/movie.dart';
import 'package:movie_list/movie_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Movie List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _request = 'https://yts.mx/api/v2/list_movies.json';
  List<dynamic> _movies = <dynamic>[];
  int _listLength = 0;
  double _rating;

  Future<void> _getMovies() async {
    final Response response = await get(_request);
    final Map<String, dynamic> data = json.decode(response.body)['data'];
    final List<dynamic> movies = data['movies'];
    final List<dynamic> movieList = movies //
        .map((dynamic item) => Movie.fromJson(item))
        .toList();
    setState(() {
      _movies = movieList;
    });
  }

  String _validateInput(String value) {
    double rating;
    if (value.isEmpty) {
      _rating = 0.0;
      return 'Please enter the rating';
    } else {
      try {
        rating = double.parse(value);
        if (rating < 0 || rating > 10) {
          _rating = 0.0;
          return 'Please enter an rating between 0 and 10';
        }
      } on FormatException {
        _rating = 0.0;
        return 'Please enter an valid rating';
      }
      _rating = rating;
      return null;
    }
  }

  void _filterMovies(double rating, bool lower) {
    List<dynamic> movies;
    if (lower) {
      movies = _movies.where((dynamic element) => double.tryParse(element.rating) < rating).toList();
    } else {
      movies = _movies.where((dynamic element) => double.tryParse(element.rating) > rating).toList();
    }
    setState(() {
      _movies = movies;
      _listLength = _movies.length;
    });
  }

  Future<void> _askedToLead() async {
    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return Form(
            key: _formKey,
            child: SimpleDialog(
              backgroundColor: Colors.black,
              title: const Center(
                child: Text('Filtering by rating', style: TextStyle(color: Colors.white)),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                        fillColor: Color(0xFF303030),
                        filled: true,
                        hintText: 'Enter the rating',
                        hintStyle: TextStyle(color: Color(0xFFD6D6D6))),
                    keyboardType: TextInputType.number,
                    validator: (String value) {
                      return _validateInput(value);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: RaisedButton(
                    textColor: Colors.white,
                    color: const Color(0xFF303030),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Navigator.pop<String>(context, 'lower');
                      }
                    },
                    child: const Text('Lower than rating received'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: RaisedButton(
                    textColor: Colors.white,
                    color: const Color(0xFF303030),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Navigator.pop<String>(context, 'higher');
                      }
                    },
                    child: const Text('Higher than rating received'),
                  ),
                ),
              ],
            ),
          );
        })) {
      case 'lower':
        _filterMovies(_rating, true);
        break;
      case 'higher':
        _filterMovies(_rating, false);
        break;
    }
  }

  void _resetMovies() {
    _getMovies();
    _listLength = 9;
  }

  dynamic _getCover(int index) {
    try {
      return Image.network(
        _movies[index].mediumCover,
        fit: BoxFit.fill,
        errorBuilder: (BuildContext context, Object error, StackTrace stackTrace) {
          return const Icon(Icons.error);
        },
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
      );
    } on RangeError {
      return const Icon(Icons.error);
    }
  }

  @override
  void initState() {
    super.initState();
    _getMovies();
    _listLength = 9;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: () {
                _askedToLead();
              }),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _resetMovies();
            },
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _listLength,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(builder: (BuildContext context) => MoviePage(movie: _movies[index])),
                );
              },
              child: _getCover(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Show more movies',
        backgroundColor: const Color(0xFF303030),
        onPressed: () {
          setState(() {
            _listLength = _movies.length;
          });
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
