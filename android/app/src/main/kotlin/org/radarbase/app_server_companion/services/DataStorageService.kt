package org.radarbase.app_server_companion.services

import android.content.Context
import com.google.gson.GsonBuilder

open class DataStorageService(c: Context) : StorageService {

    internal var cache = HashMap<String, Any>()
    private val preferences = c.getSharedPreferences("POKEMON", Context.MODE_PRIVATE)
    private val editor = preferences.edit()

    init {
        cache.putAll(this.getAll(preferences.all.keys.toList(), Any::class.java))
    }

    override fun <T> putAll(data: Map<String, T>) {
        for (d in data) {
            this.put(d.key, d.value)
        }
    }

    override fun <T> getAll(keys: List<String>, c: Class<T>): Map<String, T> {
        val localMap: HashMap<String, T> = HashMap()
        for (k in keys) {
            when {
                cache.containsKey(k) -> localMap[k] = cache[k] as T
                preferences.contains(k) -> {
                    val v = gson.fromJson(preferences.getString(k, null), c)
                    localMap[k] =  v
                    cache.put(k, v as Any)
                }
                else -> throw IllegalArgumentException("No object with key: $k was saved")
            }
        }
        return localMap
    }

    override fun <T> get(key: String, c: Class<T>): T {
        return if (cache.containsKey(key)) {
            cache[key] as T
        } else {
            val value = preferences.getString(key, null)
            if (value != null) {
                val v = gson.fromJson(value, c)
                cache[key] = v as Any
                v
            } else {
                throw IllegalArgumentException("No object with key: $key was saved")
            }
        }
    }

    override fun <T> put(key: String, value: T) {
        cache[key] = value as Any

        val inString = gson.toJson(value)
        editor.putString(key, inString).commit()
    }

    override fun <T> getOrElse(key: String, c: Class<T>, elseFunction: () -> T): T {
        return try {
            val value = this.get(key, c)
            value
        } catch (exc: IllegalArgumentException) {
            elseFunction()
        }
    }

    companion object {

        private val gson = GsonBuilder().create()
    }

}