package org.radarbase.app_server_companion.services.pokemon

import android.content.Context
import org.radarbase.app_server_companion.model.PokemonDetails
import org.radarbase.app_server_companion.services.DataStorageService

class PokemonStorageService(c: Context) : DataStorageService(c) {

    fun addPokemonToStorage(pokemon: PokemonDetails) {
        this.put("${POKEMON_STORAGE_KEY_PREFIX}${pokemon.id}", pokemon)
    }

    fun getPokemonFromStorage(id: Int): PokemonDetails {
        return this.get("${POKEMON_STORAGE_KEY_PREFIX}$id", PokemonDetails::class.java)
    }

    fun getFavouritePokemons(): List<PokemonDetails> {
        return this.cache.filter { it.key.contains(POKEMON_STORAGE_KEY_PREFIX) &&
                (it.value as PokemonDetails).isFavourite }.values as List<PokemonDetails>
    }

    companion object {
        private const val POKEMON_STORAGE_KEY_PREFIX: String = "pokemon-"
    }
}