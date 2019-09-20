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
            p["id"],
            p["name"],
            FadeInImage.assetNetwork(
              placeholder: "images/pokeball_placeholder.gif",
              image: p["thumbnailUrl"],
              imageScale: 0.30,
              placeholderScale: 2.5,
              height: 300,
            ),
            p["height"],
            p["weight"]);
      }).toList();
    });
  }

  Widget _buildFavourites() {
    getAllPokemons();
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i < _favourites.length) return _buildRow(_favourites[i]);
        return null;
      },
    );
  }

  Widget _buildRow(Pokemon pokemon) {
    return Builder(builder: (BuildContext context) {
      return Dismissible(
          // Show a red background as the item is swiped away.
          background: Container(color: Colors.red),
          key: Key(pokemon.name),
          onDismissed: (direction) {
            removeFromFavourites(pokemon);
            setState(() {
              _favourites.remove(pokemon);
            });

            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("${pokemon.name} removed from favourites"),
            ));
          },
          child: Column(children: <Widget>[
            ListTile(
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
            ),
            Divider()
          ]));
    });
  }

  Future<void> removeFromFavourites(Pokemon pokemon) async {
    int favCount;
    try {
      favCount = await _platform.invokeMethod(
          'removeFromFavourites', {"id": pokemon.id, "name": pokemon.name});
    } on PlatformException catch (e) {
      Logging.log(_TAG, "There was an exception removing from favourites : $e");
    }
  }
}

class Pokemon {
  int _id;
  String _name = "";
  FadeInImage _thumbnail;
  int _height = 0;
  int _weight = 0;

  Pokemon(this._id, this._name, this._thumbnail, this._height, this._weight);

  int get weight => _weight;

  int get height => _height;

  FadeInImage get thumbnail => _thumbnail;

  String get name => _name;

  int get id => _id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pokemon &&
          runtimeType == other.runtimeType &&
          _id == other._id &&
          _name == other._name &&
          _height == other._height &&
          _weight == other._weight;

  @override
  int get hashCode =>
      _id.hashCode ^ _name.hashCode ^ _height.hashCode ^ _weight.hashCode;
}
