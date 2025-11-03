package com.xc.pay_print;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class PaymentManager {
    private static final String TAG = "PaymentManager";
    private final MethodChannel channel;
    private final Context context;

    public PaymentManager(MethodChannel channel, Context context) {
        this.channel = channel;
        this.context = context;
    }

    /**
     * همون متدی که قبلاً استفاده می‌کردی:
     * فقط اپ TechPay رو لانچ می‌کنه و amount/orderId رو توی extras می‌فرسته.
     */
    public void startPayment(double amount, String orderId, String terminalId, String merchantId) {
        Log.d(TAG, "🚀 startPayment called amount=" + amount + " orderId=" + orderId);

        try {
            String packageName = "com.tech.pay"; // اگر اسم پکیج اپ بانکی چیز دیگه‌ایه، همین‌جا عوضش کن
            Intent intent = context.getPackageManager().getLaunchIntentForPackage(packageName);

            if (intent == null) {
                throw new Exception("TechPay app is not installed on the device");
            }

            // مبلغ به صورت عدد صحیح (مثلاً ریال)
            intent.putExtra("amount", String.valueOf((long) amount));
            intent.putExtra("packageName", context.getPackageName());
            intent.putExtra("payId", orderId);                  // شناسه‌ی پرداخت/سفارش
            intent.putExtra("transactionType", "purchase");     // یا "bill" طبق داک اپ بانکی

            // در صورت نیاز می‌تونی این دو تا رو هم استفاده کنی (اگر اپ بانکی بخونه)
            if (terminalId != null) {
                intent.putExtra("terminalId", terminalId);
            }
            if (merchantId != null) {
                intent.putExtra("merchantId", merchantId);
            }

            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);

        } catch (Exception e) {
            Log.e(TAG, "❌ Exception while starting payment intent: " + e.getMessage(), e);
            sendStatusToFlutter("failed", "Exception: " + e.getMessage());
        }
    }

    /**
     * اگر یه جایی اپ بانکی نتیجه رو با extra به همین Activity برگردونه (transaction)
     * این متد می‌تونه parse کنه و برای Flutter بفرسته.
     * الان اجباری نیست ازش استفاده کنی، ولی نگهش می‌داریم.
     */
    public void handleResultFromIntent(Intent intent) {
        if (intent == null) {
            sendStatusToFlutter("failed", "No data received from TechPay");
            return;
        }

        String transaction = intent.getStringExtra("transaction");
        if (transaction == null) {
            sendStatusToFlutter("failed", "Transaction result is null");
            return;
        }

        Log.d(TAG, "📩 TechPay result: " + transaction);

        String[] parts = transaction.split(",");
        String status = parts.length > 0 ? parts[0] : "unknown";
        String message = parts.length > 4 ? parts[4] : "No message";

        Map<String, Object> result = new HashMap<>();
        result.put("status", status);
        result.put("message", message);

        channel.invokeMethod("onPaymentResult", result);
    }

    private void sendStatusToFlutter(String status, String message) {
        Map<String, Object> result = new HashMap<>();
        result.put("status", status);
        result.put("message", message);
        channel.invokeMethod("onPaymentResult", result);
    }
}
