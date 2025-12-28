package com.xc.pay_print;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class PaymentResultActivity extends Activity {

    private static MethodChannel methodChannel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
     //   Log.d("PaymentResultActivity", "onCreate called, intent = " + getIntent());

        Intent intent = getIntent();
        Map<String, Object> result = new HashMap<>();

        if (intent != null) {
            String transaction = intent.getStringExtra("transaction");
           // Log.d("PaymentResultActivity", "transaction extra = " + transaction);

            if (transaction != null) {
                // کل رشته خام برای Flutter
                result.put("raw", transaction);
            } else {
                // fallback فقط برای زمانی که اپ پوز ساختار دیگه‌ای بفرسته
                String status = intent.getStringExtra("status");
                String message = intent.getStringExtra("message");
                result.put("status", status != null ? status : "unknown");
                result.put("message", message != null ? message : "No message");
            }

            invokePaymentResult(result);
        } else {
            Log.e("PaymentResultActivity", "❌ intent is null in onCreate");
        }

        finish();
    }

    public static void setMethodChannel(MethodChannel channel) {
       // Log.d("PaymentResultActivity", "✅ MethodChannel set");
        methodChannel = channel;
    }

    public static void invokePaymentResult(Map<String, ?> result) {
        if (methodChannel != null) {
           // Log.d("PaymentResultActivity", "📨 invokePaymentResult called with: " + result);
            methodChannel.invokeMethod("onPaymentResult", result);
        } else {
            Log.e("PaymentResultActivity", "❌ methodChannel is null, cannot send result to Flutter");
        }
    }
}
