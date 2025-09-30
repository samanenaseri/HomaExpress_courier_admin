package com.xc.pay_print

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.xc.pay_print.PaymentManager
import com.pos.sdk.cardreader.POICardManager
import com.pos.sdk.cardreader.PosMagCardReader
import com.xc.pay_print.config.EmvConfig

class MainActivity : FlutterFragmentActivity() {

    private val PRINTER_CHANNEL = "com.xc.pay_print/printer"
    private val PAYMENT_CHANNEL = "com.xc.pay_print/payment"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "🔥 onCreate called")
        EmvConfig.loadDefaultAidAndCapk()

        try {
            val cardManager = POICardManager.getDefault(this)
            val magReader = cardManager.magCardReader

            val result = magReader.open(
                PosMagCardReader.CARDREADER_DATA_TYPE_PLAIN,
                PosMagCardReader.CARDREADER_KEY_TYPE_TDK,
                -1, -1,
                0x30.toByte(),
                null
            )

            if (result == 0) {
                Log.d("MainActivity", "✅ Mag card reader opened successfully")
                val detectResult = magReader.detect()
                if (detectResult == 0) {
                    val trackData = magReader.getTraceData(PosMagCardReader.CARDREADER_TRACE_INDEX_2)
                    val cardInfo = trackData?.let { String(it) }
                    Log.d("MainActivity", "💾 Track2 Data: $cardInfo")
                } else {
                    Log.e("MainActivity", "❌ No card detected")
                }
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
        Log.d("MainActivity", "🔥 onCreate called")

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
        PaymentResultActivity.setMethodChannel(paymentChannel)
        val paymentManager = PaymentManager(paymentChannel, this)

        paymentChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startPayment" -> {
                    val amount = call.argument<int>("amount") ?: 0.0
                    val orderId = call.argument<String>("orderId") ?: "1234567890"
                    val terminalId = call.argument<String>("terminalId") ?: "51533600"
                    val merchantId = call.argument<String>("merchantId") ?: "51040293"

                    Log.d("MainActivity", "🔷 startPayment called with amount: $amount")
                    paymentManager.startPayment(amount, orderId, terminalId, merchantId)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            val cardManager = POICardManager.getDefault(this)
            Log.d("MainActivity", "✅ POICardManager released/unregistered (if applicable)")
        } catch (e: Exception) {
            Log.e("MainActivity", "💥 Error in onDestroy: ${e.message}")
        }
    }
}
