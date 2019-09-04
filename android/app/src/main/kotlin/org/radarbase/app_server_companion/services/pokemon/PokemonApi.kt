package org.radarbase.app_server_companion.services.pokemon

import org.radarbase.app_server_companion.model.PokemonDetails

interface PokemonApi {
    fun randomPokemon(): PokemonDetails

    fun pokemonById(id: Int): PokemonDetails

    fun pokemonByName(name: String): PokemonDetails

    fun pokemonByIdAndName(id: Int, name: String): PokemonDetails
}
