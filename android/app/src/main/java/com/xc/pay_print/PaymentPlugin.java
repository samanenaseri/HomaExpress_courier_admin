package com.xc.pay_print;

import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.HashMap;
import java.util.Map;

public class PaymentPlugin implements FlutterPlugin, MethodCallHandler {
    private static final String TAG = "PaymentPlugin";
    private MethodChannel channel;
    private PaymentManager paymentManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "com.xc.pay_print/payment");
        channel.setMethodCallHandler(this);
        paymentManager = new PaymentManager(channel, binding.getApplicationContext());
        Log.d(TAG, "PaymentPlugin attached to engine.");
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.d(TAG, "Received method call: " + call.method);
        switch (call.method) {
            case "startPayment":
                if (call.argument("amount") != null) {
                    double amount = (double) call.argument("amount");
                    Log.d(TAG, "Calling paymentManager.startPayment for amount: " + amount);
                    paymentManager.startPayment(amount);
                    Log.d(TAG, "Calling result.success(true).");
                    result.success(true);
                    Log.d(TAG, "Called result.success(true).");
                } else {
                    Log.e(TAG, "startPayment called with null amount argument.");
                    result.error("INVALID_ARGUMENTS", "Amount cannot be null", null);
                }
                break;
            case "onPaymentResult":
                String status = call.argument("status");
                String message = call.argument("message");
                Log.d(TAG, "Received payment result: " + status + " - " + message);
                break;
            default:
                Log.d(TAG, "Method not implemented: " + call.method);
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        Log.d(TAG, "PaymentPlugin detached from engine.");
    }
} 