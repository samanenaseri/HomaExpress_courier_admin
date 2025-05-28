package com.xc.pay_print;

import android.content.Context;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import com.pos.sdk.cardreader.POICardManager;
import com.pos.sdk.cardreader.PosMagCardReader;
import com.pos.sdk.emvcore.IPosEmvCoreListener;
import com.pos.sdk.emvcore.POIEmvCoreManager;
import com.pos.sdk.emvcore.PosEmvErrorCode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import com.pos.sdk.security.POIHsmManage;
import com.pos.sdk.security.PedKeyInfo;
import com.pos.sdk.security.PedKcvInfo;
import com.pos.sdk.utils.PosUtils; // جایگزین HexUtil


public class PaymentManager {

    private static final String TAG = "PaymentManager";
    private final MethodChannel channel;
    private final POIEmvCoreManager emvCoreManager;
    private final Context context;

    public PaymentManager(MethodChannel channel, Context context) {
        this.channel = channel;
        this.context = context;
        this.emvCoreManager = POIEmvCoreManager.getDefault();
        Log.d(TAG, "PaymentManager initialized.");
    }

    public void startPayment(double amount) {
        try {
            POICardManager cardManager = POICardManager.getDefault(context);
            POIHsmManage hsmManage = POIHsmManage.getDefault();

            // ✅ ست کردن کلید DUKPT
            byte[] key = hexStringToByteArray("0123456789ABCDEF0123456789ABCDEF");
            byte[] ksn = hexStringToByteArray("FFFF9080102495000001");

            PedKcvInfo kcvInfo = new PedKcvInfo(0, new byte[5]);

            int dukptResult = hsmManage.PedWriteTIK(
                    1, 0, key.length, key, ksn, kcvInfo
            );
            Log.d(TAG, "🔐 PedWriteTIK result: " + dukptResult);

            // باز کردن کارت‌خوان در حالت ENCRYPT_ZIOSK
            PosMagCardReader magCardReader = cardManager.getMagCardReader();
            int openResult = magCardReader.open(
                    PosMagCardReader.CARDREADER_DATA_TYPE_ENCRYPT_ZIOSK,
                    PosMagCardReader.CARDREADER_KEY_TYPE_DUKPT_DATA_REQUEST,
                    1,
                    PosMagCardReader.CARDREADER_MODE_ECB,
                    (byte) 0x30,
                    null
            );

            if (openResult != 0) {
                sendStatusToFlutter("failed", "Failed to open card reader");
                return;
            }

            Thread.sleep(300);

            new Thread(() -> {
                try {
                    Log.d(TAG, "🚀 Detect thread started");

                    int maxTries = 10; // یعنی حدود 3 ثانیه (10 * 300ms)
                    int tryCount = 0;

                    while (tryCount < maxTries) {
                        int detectResult = magCardReader.detect();
                        Log.d(TAG, "📥 detect() try " + tryCount + ": " + detectResult);

                        if (detectResult == 0) {
                            byte[] trackData = magCardReader.getTraceData(PosMagCardReader.CARDREADER_TRACE_INDEX_2);
                            if (trackData != null) {
                                String cardInfo = new String(trackData);
                                sendStatusToFlutter("success", "Card read: " + cardInfo);
                            } else {
                                sendStatusToFlutter("failed", "Track data is null");
                            }

                            magCardReader.close();
                            return;
                        }

                        tryCount++;
                        Thread.sleep(300); // صبر بین هر تلاش
                    }

                    sendStatusToFlutter("failed", "No card detected after timeout");
                    magCardReader.close();

                } catch (Exception e) {
                    Log.e(TAG, "💥 Exception during detect loop: " + e.getMessage());
                    sendStatusToFlutter("failed", "Exception: " + e.getMessage());
                }
            }).start();


        } catch (Exception e) {
            Log.e(TAG, "💥 Exception in startPayment: " + e.getMessage());
            sendStatusToFlutter("failed", "Exception in startPayment: " + e.getMessage());
        }
    }




    private byte[] hexStringToByteArray(String s) {
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                    + Character.digit(s.charAt(i+1), 16));
        }
        return data;
    }
    private void sendStatusToFlutter(String status, String message) {
        if (channel != null) {
            Map<String, Object> result = new HashMap<>();
            result.put("status", status);
            result.put("message", message);

            // ⛳ اجرای روی main thread
            new android.os.Handler(android.os.Looper.getMainLooper()).post(() -> {
                channel.invokeMethod("onPaymentResult", result);
            });
        }
    }
}
