package org.radarbase.app_server_companion

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import me.sargunvohra.lib.pokekotlin.client.PokeApiClient
import org.radarbase.app_server_companion.services.pokemon.PokemonService

class MainActivity : FlutterActivity() {
    private val CHANNEL = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        val pokemonService = PokemonService(PokeApiClient(), applicationContext)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            when {
                call.method == "addToFavourites" -> result.success(pokemonService.addToFavourites(call.argument("id"), call.argument("name")))
                call.method == "removeFromFavourites" -> result.success(pokemonService.removeFromFavourites(call.argument("id"), call.argument("name")))
                call.method == "getFavourites" -> result.success(pokemonService.getAllFavourties())
                call.method == "getRandomPokemon" -> result.success(pokemonService.randomPokemon().toJsonString())
            }
        }
    }

    companion object {
        private const val CHANNEL = "org.radarbase.app_server_companion/pokemon-service"
    }
}
