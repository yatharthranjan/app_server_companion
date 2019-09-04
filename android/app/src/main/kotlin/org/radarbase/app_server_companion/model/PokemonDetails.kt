package org.radarbase.app_server_companion.model

import com.google.gson.GsonBuilder

data class PokemonDetails(val id: Long, val name: String, val _thumbnailUrl: String,
                          val height: Int, val weight: Int, val abilities: List<String>,
                          val species: String, val types: List<String>, val moves: List<String>,
                          val isFavourite: Boolean) {

    fun toJsonString(): String {
        return gson.toJson(this)
    }

    companion object {
        private val gson = GsonBuilder().create()
    }
}