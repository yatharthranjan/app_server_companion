package org.radarbase.app_server_companion.services

interface StorageService {
    fun <T> get(key: String, c: Class<T>): T

    fun <T> put(key: String, value: T)

    fun <T> putAll(data: Map<String, T>)

    fun <T> getAll(keys: List<String>, c: Class<T>): Map<String, T>

    fun <T> getOrElse(key: String, c: Class<T>, elseFunction: ()-> T): T
}