import com.xc.pay_print.PaymentManager
import com.pos.sdk.cardreader.POICardManager
import com.pos.sdk.cardreader.PosMagCardReader
import android.os.IBinder
import android.os.Binder
import android.content.Context
import com.xc.pay_print.config.EmvConfig;
import com.xc.pay_print.config.EmvConfig

class MainActivity : FlutterFragmentActivity() {

    class MainActivity : FlutterFragmentActivity() {

        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            Log.d("MainActivity", "🔥 onCreate called")
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
                            PosMagCardReader.CARDREADER_DATA_TYPE_PLAIN,
                    PosMagCardReader.CARDREADER_KEY_TYPE_TDK,
                    -1, -1,
                    0x30.toByte(),
                    null
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
                        val cardInfo = trackData?.let { String(it) }
                        Log.d("MainActivity", "💾 Track2 Data: $cardInfo")
                    } else {
                        Log.e("MainActivity", "❌ No card detected")
                    }

                    // ✅ بستن کارت‌خوان پس از پایان
                    magReader.close()

                } else {
                    Log.e("MainActivity", "❌ Failed to open mag card reader. Code: $result")
                }
                class MainActivity : FlutterFragmentActivity() {
                }
            }


            override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
                super.configureFlutterEngine(flutterEngine)
                Log.d("MainActivity", "🔥 onCreate called")

                // Channelهای Flutter
                MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PRINTER_CHANNEL)
                    .setMethodCallHandler { call, result ->
                        val printerManager = PrinterManager(this)
                         class MainActivity : FlutterFragmentActivity() {
                    }

                        val paymentChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PAYMENT_CHANNEL)
                        PaymentResultActivity.setMethodChannel(paymentChannel)
                        val paymentManager = PaymentManager(paymentChannel, this)

                        paymentChannel.setMethodCallHandler { call, result ->
                            when (call.method) {
                                "startPayment" -> {
                                    val amount = call.argument<Double>("amount") ?: 0.0
                                    val orderId = call.argument<String>("orderId") ?: "1234567890"
                                    val terminalId = call.argument<String>("terminalId") ?: "51533600"
                                    val merchantId = call.argument<String>("merchantId") ?: "51040293"

                                    Log.d("MainActivity", "🔷 startPayment called with amount: $amount")
                                    paymentManager.startPayment(amount)
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
                        val cardManager = com.pos.sdk.cardreader.POICardManager.getDefault(this)
                        // اگه SDK متد release یا مشابه داشته باشه، اینجا صدا بزن:
                        // مثلاً:
                        // cardManager.release()  یا  cardManager.unregister()
                        val cardManager = POICardManager.getDefault(this)
                        Log.d("MainActivity", "✅ POICardManager released/unregistered (if applicable)")
                    } catch (e: Exception) {
                        Log.e("MainActivity", "💥 Error in onDestroy: ${e.message}")