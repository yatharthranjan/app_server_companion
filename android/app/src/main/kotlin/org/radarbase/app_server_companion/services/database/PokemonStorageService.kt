package org.radarbase.app_server_companion.services.database

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import io.reactivex.Completable
import io.reactivex.Flowable
import io.reactivex.Maybe
import org.radarbase.app_server_companion.model.PokemonDetails

@Dao
interface PokemonStorageService {

    @Insert
    fun addPokemonToStorage(pokemon: PokemonDetails): Completable

    @Query("SELECT * FROM POKEMON WHERE id=:id LIMIT 1")
    fun getPokemonFromStorage(id: Int): Maybe<PokemonDetails>

    @Query("SELECT * FROM POKEMON WHERE isFavourite=1")
    fun getFavouritePokemons(): Flowable<List<PokemonDetails>>

    @Delete
    fun deletePokemon(pokemon: PokemonDetails): Completable

    @Query("UPDATE POKEMON SET isFavourite=:isFavourite WHERE id=:id")
    fun updateIsFavourite(id: Int, isFavourite: Boolean): Completable
}