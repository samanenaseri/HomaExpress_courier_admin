package com.xc.pay_print;

import android.content.Context;
import android.os.Bundle;
import android.os.RemoteException;
import android.util.Log;

import com.pos.sdk.emvcore.IPosEmvCoreListener;
import com.pos.sdk.emvcore.POIEmvCoreManager;
import com.pos.sdk.security.POIHsmManage;
import com.pos.sdk.security.PedKeyInfo;
import com.pos.sdk.security.PedKcvInfo;
import com.xc.pay_print.config.EmvConfig;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class PaymentManager {
    private static final String TAG = "PaymentManager";
    private final MethodChannel channel;
    private final POIEmvCoreManager emvCoreManager;
    private final Context context;

    public PaymentManager(MethodChannel channel, Context context) {
        this.channel = channel;
        this.context = context;
        this.emvCoreManager = POIEmvCoreManager.getDefault();
        Log.d(TAG, "✅ PaymentManager initialized.");
    }

    public void startPayment(double amount) {
        try {
            Log.d(TAG, "🔁 Starting EMV Transaction...");

            // 🔐 Inject TDK Key
            POIHsmManage hsmManage = POIHsmManage.getDefault();
            byte[] tdkBytes = hexStringToByteArray("11223344556677889900AABBCCDDEEFF");
            PedKcvInfo kcvInfo = new PedKcvInfo(0, new byte[5]);

            PedKeyInfo tdk = new PedKeyInfo();
            tdk.dstKeyType = 1; // TDK
            tdk.dstKeyIdx = 1;  // PSP key index
            tdk.dstKeyLen = tdkBytes.length;
            tdk.dstKeyData = tdkBytes;

            int writeResult = hsmManage.PedWriteKey(tdk, kcvInfo);
            Log.d(TAG, "🔐 PedWriteKey result: " + writeResult);

            // 🔧 Load AID & CAPK configs
            EmvConfig.loadDefaultAidAndCapk();

            // 🧾 Prepare Transaction
            String amountStr = String.format("%012d", (long) amount);
            Bundle transBundle = new Bundle();
            transBundle.putInt("transType", 0);  // 0 = Purchase
            transBundle.putString("amount", amountStr); // "000000002100"
            transBundle.putString("transCurrencyCode", "364");
            transBundle.putString("terminalCountryCode", "364");
            transBundle.putInt("kernelType", 0);  // یا 1 برای MasterCard، یا از کارت خوان بگیری


            // ▶️ Start EMV Transaction
            emvCoreManager.startTransaction(transBundle, new IPosEmvCoreListener.Stub() {
                @Override
                public void onTransactionResult(int result, Bundle bundle) throws RemoteException {
                    Log.d(TAG, "✅ Transaction finished with result: " + result);
                    sendStatusToFlutter(result == 0 ? "success" : "failed", "Result code: " + result);
                }

                @Override
                public void onRequestOnlineProcess(Bundle requestData) throws RemoteException {
                    Log.d(TAG, "📡 Online process requested");
                    Bundle response = new Bundle();
                    response.putString("respCode", "00");
                    response.putString("authCode", "123456");
                    emvCoreManager.onSetOnlineResponse(response);
                }

                @Override public void onRequestInputPin(Bundle bundle) {}
                @Override public void onEmvProcess(int type, Bundle bundle) {}
                @Override public void onSelectApplication(List<String> list, boolean isFirstSelect) throws RemoteException {
                    emvCoreManager.onSetSelectResponse(0);
                }
                @Override public void onConfirmCardInfo(int mode, Bundle bundle) throws RemoteException {
                    emvCoreManager.onSetCardInfoResponse(new Bundle());
                }
                @Override public void onKernelType(int type) {}
                @Override public void onSecondTapCard() {}
            });

        } catch (Exception e) {
            Log.e(TAG, "💥 Exception in startPayment: " + e.getMessage());
            sendStatusToFlutter("failed", "Exception: " + e.getMessage());
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
            new android.os.Handler(android.os.Looper.getMainLooper()).post(() -> {
                channel.invokeMethod("onPaymentResult", result);
            });
        }
    }
}
