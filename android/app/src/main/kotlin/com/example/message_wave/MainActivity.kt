package com.perigeesolutions.message_wave

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() { 
  
  private val CHANNEL = "com.example.message_wave/sms"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "sendSms") {
        val phoneNumber = call.argument<String>("phoneNumber")
        val message = call.argument<String>("message")
        if (phoneNumber != null && message != null) {
          sendSms(phoneNumber, message)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "Phone number or message is null", null)
        }
      } else {
        result.notImplemented()
      }
    }
  }

  private fun sendSms(phoneNumber: String, message: String) {
    val smsManager: SmsManager = SmsManager.getDefault()
    smsManager.sendTextMessage(phoneNumber, null, message, null, null)
  }
}
