package org.radarbase.app_server_companion.services.pokemon

import android.content.Context
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import me.sargunvohra.lib.pokekotlin.client.PokeApiClient
import org.radarbase.app_server_companion.injection.Injection
import org.radarbase.app_server_companion.model.PokemonDetails
import java.io.IOException
import java.util.concurrent.TimeUnit
import java.util.logging.Logger
import kotlin.random.Random

class PokemonService(private val pokeApiClient: PokeApiClient, c: Context) : PokemonApi {

    private var favouritesCount: Int = 0

    private val db = Injection.getDatabase(c)

    private val composeiteDisposable = CompositeDisposable()

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
        val pokemonId = Random.nextInt(1, NUMBER_OF_POKEMONS)
        logger.info("Random Pokemon Id is: $pokemonId")
        return pokemonById(pokemonId)
    }

    override fun pokemonById(id: Int): PokemonDetails {
        return try {
            logger.info("Getting Pokemon from Storage...")
            this.db.pokemonDao().getPokemonFromStorage(id)
                    .subscribeOn(Schedulers.io())
                    .timeout(20, TimeUnit.SECONDS)
                    .blockingGet()!!
        } catch (exc: Exception) {
            logger.info("Exception: $exc")
            getPokemonFromApi(id)
        }
    }

    fun getPokemonFromApi(id: Int): PokemonDetails {
        logger.info("Getting Pokemon from API...")
        val pokemon = pokeApiClient.getPokemon(id)
        val pokemonDetails = PokemonDetails(pokemon.id, pokemon.name, pokemon.sprites.frontDefault
                ?: pokemon.sprites.frontShiny ?: "", pokemon.height,
                pokemon.weight, pokemon.abilities.map { it.ability.name }, pokemon.species.name,
                pokemon.types.map { it.type.name }, pokemon.moves.map { it.move.name }, false)
        logger.info("Got Pokemon from API: $pokemonDetails")
        if (this.db.pokemonDao().addPokemonToStorage(pokemonDetails)
                        .subscribeOn(Schedulers.io())
                        .blockingAwait(20, TimeUnit.SECONDS)) {
            return pokemonDetails
        } else {
            throw IOException("Cannot Store Pokemon details in the database.")
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
        this.db.pokemonDao().updateIsFavourite(id = pokemon.id, isFavourite = true)
                .subscribeOn(Schedulers.io()).blockingAwait()
        logger.info("Successfully added to favourites...")
        return ++favouritesCount
    }

    fun removeFromFavourites(id: Int?, name: String?): Int {
        val pokemon: PokemonDetails = when {
            id != null && name != null -> this.pokemonByIdAndName(id, name)
            name != null -> this.pokemonByName(name)
            id != null -> this.pokemonById(id)
            else -> throw IllegalArgumentException("Either Id or Name must be specified. ")
        }
        this.db.pokemonDao().updateIsFavourite(id = pokemon.id, isFavourite = false)
                .subscribeOn(Schedulers.io()).blockingAwait()
        logger.info("Successfully removed from favourites...")
        return --favouritesCount
    }

    fun getAllFavourties(): List<PokemonDetails> = this.db.pokemonDao().getFavouritePokemons()
            .subscribeOn(Schedulers.io()).blockingFirst()

    companion object {
        private const val NUMBER_OF_POKEMONS: Int = 800
        private val logger = Logger.getLogger(PokemonService::class.java.name)
    }
}