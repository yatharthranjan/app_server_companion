package org.radarbase.app_server_companion.services.pokemon

import android.content.Context
import me.sargunvohra.lib.pokekotlin.client.PokeApiClient
import org.radarbase.app_server_companion.model.PokemonDetails
import java.util.logging.Logger
import kotlin.random.Random

class PokemonService(private val pokeApiClient: PokeApiClient, c: Context) : PokemonApi {

    private var favouritesCount: Int = 0

    private val storageService: PokemonStorageService = PokemonStorageService(c)

    init {
        favouritesCount = this.getAllFavourties().size
        logger.info("Favourites Size: $favouritesCount")
    }


    override fun pokemonByIdAndName(id: Int, name: String): PokemonDetails {
        val pokemonDetails = pokemonById(id)
        require(pokemonDetails.name.contentEquals(name)) { "The given ID does not match with the name." }
        return pokemonDetails
    }

    override fun randomPokemon(): PokemonDetails {
        val pokemonId = randomGenerator.nextInt()
        return pokemonById(pokemonId)
    }

    override fun pokemonById(id: Int): PokemonDetails {
        return try {
            this.storageService.getPokemonFromStorage(id)
        } catch (exc: IllegalArgumentException) {
            val pokemon = pokeApiClient.getPokemon(id)
            logger.info("Got Pokemon from API: $pokemon")
            val pokemonDetails = PokemonDetails(pokemon.id.toLong(), pokemon.name, "", pokemon.height,
                    pokemon.weight, pokemon.abilities.map { it.ability.name }, pokemon.species.name,
                    pokemon.types.map { it.type.name }, pokemon.moves.map { it.move.name }, false)
            this.storageService.addPokemonToStorage(pokemonDetails)
            pokemonDetails
        }
    }

    override fun pokemonByName(name: String): PokemonDetails {
        TODO("not implemented")
    }

    fun addToFavourites(id: Int?, name: String?): Int {
        val pokemon: PokemonDetails = when {
            id != null && name != null -> this.pokemonByIdAndName(id, name)
            name != null -> this.pokemonByName(name)
            id != null -> this.pokemonById(id)
            else -> throw IllegalArgumentException("Either Id or Name must be specified ")
        }
        this.storageService.addPokemonToStorage(pokemon.copy(isFavourite = true))
        return ++favouritesCount
    }

    fun removeFromFavourites(id: Int?, name: String?): Int {
        val pokemon: PokemonDetails = when {
            id != null && name != null -> this.pokemonByIdAndName(id, name)
            name != null -> this.pokemonByName(name)
            id != null -> this.pokemonById(id)
            else -> throw IllegalArgumentException("Either Id or Name must be specified. ")
        }
        this.storageService.addPokemonToStorage(pokemon.copy(isFavourite = false))
        return --favouritesCount
    }

    fun getAllFavourties(): List<PokemonDetails> {
        return this.storageService.getFavouritePokemons()
    }

    companion object {
        private const val NUMBER_OF_POKEMONS: Int = 10000
        private val randomGenerator: Random = Random(NUMBER_OF_POKEMONS)
        private val logger = Logger.getLogger(PokemonService::class.java.name)
    }
}