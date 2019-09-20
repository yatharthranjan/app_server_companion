package org.radarbase.app_server_companion

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import me.sargunvohra.lib.pokekotlin.client.PokeApiClient
import org.radarbase.app_server_companion.model.PokemonDetails
import org.radarbase.app_server_companion.services.pokemon.PokemonService
import java.util.logging.Logger
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        val pokemonService = PokemonService(PokeApiClient(), applicationContext)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            when {
                call.method == "addToFavourites" -> result.success(pokemonService.addToFavourites(call.argument("id"), call.argument("name")))
                call.method == "removeFromFavourites" -> result.success(pokemonService.removeFromFavourites(call.argument("id"), call.argument("name")))
                call.method == "getFavourites" -> result.success(pokemonService.getAllFavourties().map { it.toJsonString() })
                call.method == "getRandomPokemon" -> {
                    logger.info("Method called: getRandomPokemon")
                    try {
                        var pokemon: PokemonDetails? = null
                        thread(start = true) {
                            pokemon = pokemonService.randomPokemon()
                        }.join()
                        result.success(pokemon?.toJsonString())
                    } catch (exc: Exception) {
                        result.error(exc.toString(), null, null)
                    }
                }
            }
        }
    }

    companion object {
        private const val CHANNEL = "org.radarbase.app_server_companion/pokemon-service"
        private val logger = Logger.getLogger(MainActivity::class.java.name)
    }
}
