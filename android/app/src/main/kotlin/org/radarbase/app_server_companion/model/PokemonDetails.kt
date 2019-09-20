package org.radarbase.app_server_companion.model

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.TypeConverters
import com.google.gson.GsonBuilder
import org.radarbase.app_server_companion.services.database.StringListConverter

@TypeConverters(StringListConverter::class)
@Entity(tableName = "POKEMON")
data class PokemonDetails(@PrimaryKey val id: Int, val name: String, val thumbnailUrl: String,
                          val height: Int, val weight: Int,
                          val abilities: List<String>,
                          val species: String,
                          val types: List<String>,
                          val moves: List<String>,
                          val isFavourite: Boolean) {

    fun toJsonString(): String {
        return gson.toJson(this)
    }

    companion object {
        private val gson = GsonBuilder().create()
    }
}