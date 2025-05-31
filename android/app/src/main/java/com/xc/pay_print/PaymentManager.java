package com.xc.pay_print;

import android.content.Context;
import android.os.Bundle;
import android.os.RemoteException;
import android.util.Log;

import com.pos.sdk.cardreader.POICardManager;
import com.pos.sdk.emvcore.IPosEmvCoreListener;
import com.pos.sdk.emvcore.POIEmvCoreManager;
import com.pos.sdk.emvcore.PosEmvAid;
import com.pos.sdk.emvcore.PosEmvCapk;
import com.pos.sdk.security.POIHsmManage;
import com.pos.sdk.security.PedKeyInfo;
import com.pos.sdk.security.PedKcvInfo;

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
        Log.d(TAG, "PaymentManager initialized.");
    }

    public void startPayment(double amount) {
        try {
            Log.d(TAG, "\uD83D\uDD01 Starting EMV Transaction...");

            // Set up TDK key injection
            POIHsmManage hsmManage = POIHsmManage.getDefault();
            byte[] tdkBytes = hexStringToByteArray("11223344556677889900AABBCCDDEEFF");
            PedKcvInfo kcvInfo = new PedKcvInfo(0, new byte[5]);

            PedKeyInfo tdk = new PedKeyInfo();
            tdk.dstKeyType = 1; // TDK
            tdk.dstKeyIdx = 1;  // PSP index
            tdk.dstKeyLen = tdkBytes.length;
            tdk.dstKeyData = tdkBytes;

            int writeResult = hsmManage.PedWriteKey(tdk, kcvInfo);
            Log.d(TAG, "\uD83D\uDD10 PedWriteKey result: " + writeResult);

            // Inject AIDs
            String[] aidList = {
                    "A0000005591010", "A0000006021010", "A000000333010101",
                    "A0000000031010", "A0000000041010", "A0000000032010",
                    "A0000000980840", "A00000002501", "A0000003241010"
            };

            for (String aidHex : aidList) {
                PosEmvAid aid = new PosEmvAid();
                aid.AID = hexStringToByteArray(aidHex);
                aid.FloorLimit = 10000;
                aid.TargetPercentage = 100;
                aid.MaxTargetPercentage = 0;
                aid.TACOnline = hexStringToByteArray("DC4004F800");
                aid.TACDefault = hexStringToByteArray("DC4000A800");
                aid.TACDenial = hexStringToByteArray("0010000000");
                aid.SelectIndicator = true;
                aid.TypeIndicator = false;
                emvCoreManager.EmvSetAid(aid);
            }

            // Inject CAPK
//            PosEmvCapk capk = new PosEmvCapk();
//            capk.RID = hexStringToByteArray("A000000559");
//            capk.CapkIndex = (byte) 0x01;
//            capk.Module = hexStringToByteArray("C2E89C438B2B... (کامل کن)");
//            capk.Exponent = hexStringToByteArray("03");
//            capk.Checksum = hexStringToByteArray("A1B2C3");
//            capk.AlgorithmInd = PosEmvCapk.ALGO_IND_RSA;
//            capk.HashInd = PosEmvCapk.HASH_IND_SHA1;
//            emvCoreManager.EmvSetCapk(capk);
//


// ====== CAPK Test Sample ======
            PosEmvCapk capk = new PosEmvCapk();
            capk.RID = hexStringToByteArray("A000000003");
            capk.CapkIndex = (byte) 0x01;
            capk.Module = hexStringToByteArray("AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899");
            capk.Exponent = hexStringToByteArray("03");
            capk.Checksum = new byte[20];  // تستی خالی
            capk.AlgorithmInd = (byte) 0x01;
            capk.HashInd = (byte) 0x01;
            emvCoreManager.EmvSetCapk(capk);

// ====== AID Test Sample ======
            PosEmvAid aid = new PosEmvAid();
            aid.AID = hexStringToByteArray("A0000000031010");
            aid.SelectIndicator = true;
            aid.TypeIndicator = true;
            aid.TACDefault = hexStringToByteArray("DC4000A800");
            aid.TACDenial = hexStringToByteArray("0010000000");
            aid.TACOnline = hexStringToByteArray("DC4004F800");
            aid.FloorLimit = 0;
            aid.Threshold = 0;
            aid.TargetPercentage = 0;
            aid.MaxTargetPercentage = 0;
            aid.TransCurrencyCode = hexStringToByteArray("0364");
            aid.TransCurrencyExp = hexStringToByteArray("02");
            aid.TerminalCountryCode = hexStringToByteArray("0364");
            aid.TerminalType = hexStringToByteArray("22");
            aid.TerminalCapabilities = hexStringToByteArray("E0F0C8");
            aid.AdditionalTerminalCapabilities = hexStringToByteArray("6000F0A001");
            emvCoreManager.EmvSetAid(aid);

            String amountStr = String.format("%012d", (int) amount);
            Bundle transBundle = new Bundle();
            transBundle.putInt("transType", 0);
            transBundle.putString("amount", amountStr);
            transBundle.putString("transCurrencyCode", "364");


            emvCoreManager.startTransaction(transBundle, new IPosEmvCoreListener.Stub() {
                @Override
                public void onTransactionResult(int result, Bundle bundle) throws RemoteException {
                    Log.d(TAG, "\u2705 Transaction finished with result: " + result);
                    sendStatusToFlutter(result == 0 ? "success" : "failed", "Result code: " + result);
                }

                @Override
                public void onRequestOnlineProcess(Bundle requestData) throws RemoteException {
                    Log.d(TAG, "\uD83D\uDCF1 Online process requested");
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
            Log.e(TAG, "\uD83D\uDCA5 Exception in startPayment: " + e.getMessage());
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
