package com.xc.pay_print

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.xc.pay_print.PaymentManager
import com.pos.sdk.cardreader.POICardManager
import com.pos.sdk.cardreader.PosMagCardReader
import android.os.IBinder
import android.os.Binder
import android.content.Context
import com.xc.pay_print.config.EmvConfig;

class MainActivity : FlutterFragmentActivity() {

    private val PRINTER_CHANNEL = "com.xc.pay_print/printer"
    private val PAYMENT_CHANNEL = "com.xc.pay_print/payment"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        EmvConfig.loadDefaultAidAndCapk()

        try {
            val cardManager = POICardManager.getDefault(this)
            val magReader = cardManager.magCardReader

            val result = magReader.open(
                PosMagCardReader.CARDREADER_DATA_TYPE_PLAIN,  // plain data
                PosMagCardReader.CARDREADER_KEY_TYPE_TDK,     // key type
                -1, -1,                                        // key index & mode
                0x30.toByte(),                                 // padding
                null                                           // init vector
            )

            if (result == 0) {
                Log.d("MainActivity", "✅ Mag card reader opened successfully")

                // 🕒 منتظر کشیدن کارت
                val detectResult = magReader.detect()
                if (detectResult == 0) {
                    Log.d("MainActivity", "💳 Card swiped!")

                    val trackData = magReader.getTraceData(PosMagCardReader.CARDREADER_TRACE_INDEX_2)
                    if (trackData != null) {
                        val cardInfo = String(trackData)
                        Log.d("MainActivity", "💾 Track2 Data: $cardInfo")
                    } else {
                        Log.e("MainActivity", "❌ Failed to get track data")
                    }
                } else {
                    Log.e("MainActivity", "❌ No card detected")
                }

                // ✅ بستن کارت‌خوان پس از پایان
                magReader.close()

            } else {
                Log.e("MainActivity", "❌ Failed to open mag card reader. Code: $result")
            }

        } catch (e: Exception) {
            Log.e("MainActivity", "💥 Exception in card reader: ${e.message}")
        }
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Channelهای Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PRINTER_CHANNEL)
            .setMethodCallHandler { call, result ->
                val printerManager = PrinterManager(this)
                when (call.method) {
                    "printReceipt" -> {
                        val lines = call.argument<List<String>>("lines")?.toTypedArray()
                            ?: arrayOf("Default line")
                        printerManager.printReceipt(lines)
                        result.success("Printed")
                    }
                    "print" -> {
                        printerManager.print()
                        result.success("Printed single line")
                    }
                    else -> result.notImplemented()
                }
            }

        val paymentChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PAYMENT_CHANNEL)
        val paymentManager = PaymentManager(paymentChannel, this)

        paymentChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startPayment" -> {
                    val amount = call.argument<Double>("amount") ?: 0.0
                    Log.d("MainActivity", "🔷 startPayment called with amount: $amount")
                    paymentManager.startPayment(amount)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
    override fun onDestroy() {
        super.onDestroy()
        try {
            val cardManager = com.pos.sdk.cardreader.POICardManager.getDefault(this)
            // اگه SDK متد release یا مشابه داشته باشه، اینجا صدا بزن:
            // مثلاً:
            // cardManager.release()  یا  cardManager.unregister()
            Log.d("MainActivity", "✅ POICardManager released/unregistered (if applicable)")
        } catch (e: Exception) {
            Log.e("MainActivity", "💥 Error in onDestroy: ${e.message}")
        }
    }
}
