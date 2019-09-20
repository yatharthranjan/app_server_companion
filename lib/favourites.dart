import 'dart:convert';

import 'package:app_server_companion/logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Favourites extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FavouritesState();
}

class FavouritesState extends State<Favourites> {
  static const String _TAG = "Favourites";
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  static const _platform =
      MethodChannel("org.radarbase.app_server_companion/pokemon-service");

  List<Pokemon> _favourites = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favourites"),
      ),
      body: _buildFavourites(),
    );
  }

  Future<void> getAllPokemons() async {
    List<dynamic> stringPokemons;
    try {
      stringPokemons = await _platform.invokeMethod('getFavourites');
    } on PlatformException catch (e) {
      Logging.log(_TAG, "There was an exception getting pokemons : $e");
    }
    setState(() {
      _favourites = stringPokemons.map((sp) {
        dynamic p = json.decode(sp);
        return Pokemon(
          p["name"],
          FadeInImage.assetNetwork(
            placeholder: "images/pokeball_placeholder.gif",
            image: p["thumbnailUrl"],
            imageScale: 0.30,
            placeholderScale: 2.5,
            height: 300,
          ),
          p["height"],
          p["weight"]);}).toList();
    });
  }

  Widget _buildFavourites() {
    getAllPokemons();
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          if (index < _favourites.length) return _buildRow(_favourites[index]);
          return null;
        });
  }

  Widget _buildRow(Pokemon pokemon) {
    return ListTile(
      leading: pokemon.thumbnail,
      title: Text(
        pokemon.name,
        style: _biggerFont,
      ),
      trailing: Icon(
        Icons.favorite,
        color: Colors.red,
      ),
      subtitle: Row(children: <Widget>[
        Text("Weight: ${pokemon.weight},  "),
        Text("Height: ${pokemon.height}"),
      ]),
      onTap: () {
        setState(() {
//          if (alreadySaved) {
//            _saved.remove(wordPair);
//          } else {
//            _saved.add(wordPair);
//          }
        });
      },
    );
  }
}

class Pokemon {
  String _name = "";
  FadeInImage _thumbnail;
  int _height = 0;
  int _weight = 0;

  Pokemon(this._name, this._thumbnail, this._height, this._weight);

  int get weight => _weight;

  int get height => _height;

  FadeInImage get thumbnail => _thumbnail;

  String get name => _name;
}
