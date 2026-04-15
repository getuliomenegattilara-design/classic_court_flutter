package com.example.classic_court

import android.os.Bundle
import android.webkit.WebStorage
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Limpa todo cache e storage do WebView ao iniciar
        android.webkit.WebView(this).apply {
            clearCache(true)
            clearHistory()
        }
        WebStorage.getInstance().deleteAllData()
    }
}
