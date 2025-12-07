package com.xc.pay_print

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.pos.sdk.cardreader.POICardManager
import com.pos.sdk.cardreader.PosMagCardReader
import com.xc.pay_print.config.EmvConfig
import android.content.Intent
import android.widget.Toast

class MainActivity : FlutterFragmentActivity() {

    private val PRINTER_CHANNEL = "com.xc.pay_print/printer"
    private val PAYMENT_CHANNEL = "com.xc.pay_print/payment"

    private lateinit var paymentManager: PaymentManager
    private lateinit var paymentChannel: MethodChannel   // 👈 اینو اضافه کن

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
                -1,
                -1,
                0x30.toByte(),
                null
            )

            if (result == 0) {
                Log.d("MainActivity", "✅ Mag card reader opened successfully")
                val detectResult = magReader.detect()
                if (detectResult == 0) {
                    val trackData =
                        magReader.getTraceData(PosMagCardReader.CARDREADER_TRACE_INDEX_2)
                    val cardInfo = trackData?.let { String(it) }
                    Log.d("MainActivity", "💾 Track2 Data: $cardInfo")
                } else {
                    Log.e("MainActivity", "❌ No card detected")
                }
                magReader.close()
            } else {
                Log.e(
                    "MainActivity",
                    "❌ Failed to open mag card reader. Code: $result"
                )
            }

        } catch (e: Exception) {
            Log.e("MainActivity", "💥 Exception in card reader: ${e.message}")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d("MainActivity", "🔥 configureFlutterEngine called")

        // کانال پرینتر
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PRINTER_CHANNEL
        ).setMethodCallHandler { call, result ->
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

        // کانال پرداخت
        paymentChannel = MethodChannel(          // 👈 دیگه val لوکال نیست، فیلد کلاس است
            flutterEngine.dartExecutor.binaryMessenger,
            PAYMENT_CHANNEL
        )

        // PaymentResultActivity الان لازم نیست، می‌تونی حذفش کنی اگر خواستی
        // PaymentResultActivity.setMethodChannel(paymentChannel)

        paymentManager = PaymentManager(paymentChannel, this)

        paymentChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startPayment" -> {
                    val amount = call.argument<Double>("amount") ?: 0.0
                    val orderId = call.argument<String>("orderId") ?: "1234567890"
                    val terminalId = call.argument<String>("terminalId") ?: "51533600"
                    val merchantId = call.argument<String>("merchantId") ?: "51040293"
                    Log.d(
                        "MainActivity",
                        "🔷 startPayment called with amount: $amount, orderId: $orderId"
                    )
                    paymentManager.startPayment(amount, orderId, terminalId, merchantId)
                    result.success(null)
                }

                // این متد عملاً استفاده نمی‌شود؛ اگر خواستی درستش کن یا حذفش کن
                "isPaymentAppInstalled" -> {     // 👈 اون فاصله قبل از اسم متد رو هم درست کردم
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        val trx = intent.getStringExtra("transaction")
        Log.d("TechPay", "onNewIntent called, transaction = $trx")

        if (trx != null) {
            // فقط برای این‌که مطمئن شی callback میاد
            Toast.makeText(this, trx, Toast.LENGTH_LONG).show()

            // 👈 اینجا نتیجه رو برای Flutter می‌فرستیم
            if (::paymentChannel.isInitialized) {
                val map = HashMap<String, Any>()
                map["raw"] = trx

                // طبق داک: ایندکس 0 = وضعیت، 1 = مبلغ، 2 = تاریخ و زمان، 3 = کد شاپرک، ...
                val parts = trx.split(",")
                if (parts.isNotEmpty()) {
                    map["status"] = parts[0]
                }
                if (parts.size > 4) {
                    map["message"] = parts[4]
                }

                Log.d("TechPay", "sending onPaymentResult to Flutter: $map")
                paymentChannel.invokeMethod("onPaymentResult", map)
            } else {
                Log.e("TechPay", "paymentChannel is NOT initialized")
            }
        } else {
            Log.d("TechPay", "onNewIntent called but transaction extra is null")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            val cardManager = POICardManager.getDefault(this)
            Log.d(
                "MainActivity",
                "✅ POICardManager released/unregistered (if applicable)"
            )
        } catch (e: Exception) {
            Log.e("MainActivity", "💥 Error in onDestroy: ${e.message}")
        }
    }
}
