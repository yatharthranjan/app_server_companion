import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PokemonCardDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PokemonCardDetailsState();
}

class PokemonCardDetailsState extends State<PokemonCardDetails> {
  static const _platform =
      MethodChannel("org.radarbase.app_server_companion/pokemon-service");

  String _name = "";
  Image _thumbnail = Image.asset("images/pokeball_default.png");
  int _id = 0;
  int _height = 0;
  int _weight = 0;
  List _moves = [];
  List _abilities = [];

  static TextStyle _titleStyle = const TextStyle(fontSize: 18);
  static TextStyle _italicStyle = const TextStyle(fontStyle: FontStyle.italic,);
  bool _isFavourite = false;

  @override
  Widget build(BuildContext context) {
    _getRandomPokemonData();
    return Card(
      child: Column(
        children: <Widget>[
          _thumbnail,
          Row(
            children: <Widget>[
              Text(
                _name,
                style: _titleStyle,
              ),
              IconButton(
                icon: Icon(
                    _isFavourite ? Icons.favorite_border : Icons.favorite,
                    color: _isFavourite ? Colors.red : null),
                onPressed: _toggleFavourite,
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              Icon(Icons.flare),
              Text("Moves", style: _italicStyle,),
              Text(_moves.toString()),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              Icon(Icons.brightness_auto),
              Text("Abilities", style: _italicStyle,),
              Text(_abilities.toString()),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              Icon(Icons.accessibility),
              Text("Physical Attributes", style: _italicStyle,),
              Row(children: <Widget>[
                Text("Weight: $_weight"),
                Text("Height: $_height"),
              ]),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
      ),
      elevation: 20,
    );
  }

  void _toggleFavourite() {
    setState(() {
      if (_isFavourite) {
        // TODO Set to not favourite in the backend
      } else {
        // TODO Set to Favourite in the backend
      }
    });
  }

  void _getRandomPokemonData() {
    Future<void> _getPokemon() async {
      dynamic jsonPokemon;
      try {
        jsonPokemon = await _platform.invokeMethod('getRandomPokemon');
      } on PlatformException catch (e) {
        log("There was an exception getting pokemon details : $e");
        _name = "Error: $e";
      }

      setState(() {
        _name = jsonPokemon["name"];
        _height = jsonPokemon["height"];
        _weight = jsonPokemon["weight"];
        _abilities = jsonPokemon["abilities"];
        _moves = jsonPokemon["moves"];
        _isFavourite = jsonPokemon["isFavourite"];
        _id = jsonPokemon["id"];
        // TODO get thumbnail url as image
      });
    }
  }
}
