package io.github.brucezhang1993.ngxda

import android.os.Bundle
import android.os.Build

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity(): FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.LOLLIPOP) {
      getWindow().setStatusBarColor(0);
    }
    GeneratedPluginRegistrant.registerWith(this)
  }
}
