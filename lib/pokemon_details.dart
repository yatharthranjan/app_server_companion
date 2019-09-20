import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:app_server_companion/logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PokemonCardDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PokemonCardDetailsState();
}

class PokemonCardDetailsState extends State<PokemonCardDetails> {
  static const String _TAG = "PokemonCardDetails";

  static const _platform =
      MethodChannel("org.radarbase.app_server_companion/pokemon-service");

  String _name = "";
  FadeInImage _thumbnail;
  int _id = -9999;
  int _height = 0;
  int _weight = 0;
  List _moves = [];
  List _abilities = [];
  int _favCount = 0;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      getPokemon();
    });
  }

  static TextStyle _titleStyle = const TextStyle(fontSize: 18);
  static TextStyle _italicStyle = const TextStyle(
    fontStyle: FontStyle.italic,
  );
  bool _isFavourite = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            child: _thumbnail,
          ),
          Row(
            children: <Widget>[
              Text(
                _name,
                style: _titleStyle,
              ),
              IconButton(
                icon: Icon(
                    _isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavourite ? Colors.red : null),
                onPressed: _toggleFavourite,
              ),
              CupertinoButton(
                child: Icon(Icons.refresh),
                onPressed: getPokemon,
                padding: EdgeInsets.all(0),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            children: <Widget>[
              Container(
                child: Icon(Icons.flare),
                padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
              ),
              Text(
                "MOVES:  ",
                style: _italicStyle,
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Text(_moves.toString()),
                scrollDirection: Axis.horizontal,
              )),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              Container(
                child: Icon(
                  Icons.brightness_auto,
                ),
                padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
              ),
              Text(
                "ABILITIES:  ",
                style: _italicStyle,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_abilities.toString()),
                  scrollDirection: Axis.horizontal,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          Row(
            children: <Widget>[
              Container(
                child: Icon(Icons.accessibility),
                padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
              ),
              Text(
                "Physical Attributes:  ",
                style: _italicStyle,
              ),
              Row(children: <Widget>[
                Text("Weight: $_weight,  "),
                Text("Height: $_height"),
              ]),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Future<void> getPokemon() async {
    dynamic stringPokemon;
    try {
      stringPokemon = await _platform.invokeMethod('getRandomPokemon');
    } on PlatformException catch (e) {
      Logging.log(_TAG, "There was an exception getting pokemon details : $e");
      _name = "Error: $e";
    }

    setState(() {
      dynamic jsonPokemon = json.decode(stringPokemon);
      _name = jsonPokemon["name"];
      _height = jsonPokemon["height"];
      _weight = jsonPokemon["weight"];
      _abilities = jsonPokemon["abilities"];
      _moves = jsonPokemon["moves"];
      _isFavourite = jsonPokemon["isFavourite"];
      _id = jsonPokemon["id"];
      _thumbnail = FadeInImage.assetNetwork(
        placeholder: "images/pokeball_placeholder.gif",
        image: jsonPokemon["thumbnailUrl"],
        imageScale: 0.30,
        placeholderScale: 2.5,
        height: 300,
      );
    });
  }

  Future<void> _toggleFavourite() async {
    int favCount;
    if (_isFavourite) {
      try {
        favCount = await _platform
            .invokeMethod('removeFromFavourites', {"id": _id, "name": _name});
        setState(() {
          _isFavourite = false;
          _favCount = favCount;
        });
      } on PlatformException catch (e) {
        Logging.log(
            _TAG, "There was an exception getting pokemon details : $e");
        _name = "Error: $e";
      }
    } else {
      try {
        favCount = await _platform
            .invokeMethod('addToFavourites', {"id": _id, "name": _name});
        setState(() {
          _isFavourite = true;
          _favCount = favCount;
        });
      } on PlatformException catch (e) {
        Logging.log(
            _TAG, "There was an exception getting pokemon details : $e");
        _name = "Error: $e";
      }
    }
  }
}
