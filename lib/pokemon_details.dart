import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PokemonCardDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return null;
  }
}

class PokemonCardDetailsState extends State<PokemonCardDetails> {
  static const _platform =
  MethodChannel("org.radarbase.app_server_companion/pokemon-service");

  String _name;
  Image _thumbnail;
  int _id;
  int _height;
  int _weight;
  List _moves;
  List _abilities;


  static TextStyle _titleStyle = const TextStyle(fontSize: 18);
  bool _isFavourite = false;

  @override
  Widget build(BuildContext context) {
    _getRandomPokemonData();
    // TODO: implement build
    return Card(
      child: Column(
        children: <Widget>[
          _thumbnail,
          ListTile(
              title: Text(
                _name,
                style: _titleStyle,
              ),
              trailing: IconButton(
                icon: Icon(
                    _isFavourite ? Icons.favorite_border : Icons.favorite,
                    color: _isFavourite ? Colors.red : null),
                onPressed: _toggleFavourite,
              )),
          ListTile(
            leading: Icon(Icons.flare),
            title: Text("Moves"),
            subtitle: Text(_moves.toString()),
          ),
          ListTile(
            leading: Icon(Icons.brightness_auto),
            title: Text("Abilities"),
            subtitle: Text(_abilities.toString()),
          ),
          ListTile(
            leading: Icon(Icons.accessibility),
            title: Text("Physical Attributes"),
            subtitle: Row(
               children: <Widget> [
                 Text("Weight: $_weight"),
                 Text("Height: $_height"),
              ]
            ),
          )
        ],
      ),
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
      try {
        final jsonPokemon = await _platform.invokeMethod(
            'getRandomPokemon');
      } on PlatformException catch (e) {
        log("There was an exception getting pokemon details : $e");
        _name = "Error: $e";
      }


      setState(() {

      });
    }
    // TODO get data from service(kotlin) and set the values
  }
}
