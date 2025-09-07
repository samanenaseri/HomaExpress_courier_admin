package com.xc.pay_print;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class PaymentResultActivity extends Activity {

    private static final String TAG = "PaymentResultActivity";
    public static MethodChannel channel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.d(TAG, "📥 PaymentResultActivity launched");

        Intent intent = getIntent();
        if (intent != null) {
            String status = intent.getStringExtra("EXTRA_PAYMENT_RESULT");
            String rrn = intent.getStringExtra("EXTRA_RRN");
            String trace = intent.getStringExtra("EXTRA_TRACE_NO");
            String message = intent.getStringExtra("EXTRA_RESULT_MESSAGE");

            Log.d(TAG, "✅ Payment result: " + status + ", RRN: " + rrn + ", trace: " + trace);

            if (channel != null) {
                Map<String, Object> result = new HashMap<>();
                result.put("status", status);
                result.put("rrn", rrn);
                result.put("trace", trace);
                result.put("message", message);

                channel.invokeMethod("onPaymentResult", result);
            }
        } else {
            Log.e(TAG, "❌ No intent received");
        }

        finish();
    }

    // Set channel reference from MainActivity or Plugin
    public static void setMethodChannel(MethodChannel methodChannel) {
        channel = methodChannel;
    }
}
