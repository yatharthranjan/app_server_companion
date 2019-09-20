package org.radarbase.app_server_companion.injection

import android.content.Context
import org.radarbase.app_server_companion.services.database.AppDatabase

object Injection {
    fun getDatabase(context: Context): AppDatabase {
        return AppDatabase.getInstance(context)
    }
}