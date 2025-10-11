package com.xc.pay_print;

import android.content.Context;
import android.os.Bundle;
import android.os.RemoteException;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;

import com.pos.sdk.emvcore.IPosEmvCoreListener;
import com.pos.sdk.emvcore.POIEmvCoreManager;
import com.pos.sdk.security.POIHsmManage;
import com.pos.sdk.security.PedKeyInfo;
import com.pos.sdk.security.PedKcvInfo;
import com.xc.pay_print.config.EmvConfig;
import com.pos.sdk.printer.POIPrinterManager;
import com.pos.sdk.printer.models.TextPrintLine;


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
        public void startPayment(double amount, String orderId, String terminalId, String merchantId) {
            Log.d(TAG, "🚀 startPayment called with amount: " + amount);

            try {
                Log.d(TAG, "🔁 Starting EMV Transaction...");
                Log.d(TAG, "⚙️ emvCoreManager: " + (emvCoreManager == null ? "null" : "ok"));

                // 🔐 Inject TDK Key
                POIHsmManage hsmManage = POIHsmManage.getDefault();
                byte[] tdkBytes = hexStringToByteArray("11223344556677889900AABBCCDDEEFF");
                PedKcvInfo kcvInfo = new PedKcvInfo(0, new byte[5]);

                PedKeyInfo tdk = new PedKeyInfo();
                tdk.dstKeyType = POIHsmManage.PED_TDK; // TDK
                tdk.dstKeyIdx = 1;  // PSP key index
                tdk.dstKeyLen = tdkBytes.length;
                tdk.dstKeyData = tdkBytes;

//            int writeResult = hsmManage.PedWriteKey(tdk, kcvInfo);
//            Log.d(TAG, "🔐 PedWriteKey result: " + writeResult);

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
                try{
                    emvCoreManager.startTransaction(transBundle, new IPosEmvCoreListener.Stub() {
                        // افزودن فراخوانی چاپ در پایان onTransactionResult اگر موفق بود
                        @Override
                        public void onTransactionResult(int result, Bundle bundle) throws RemoteException {
                            Log.d(TAG, "✅ Transaction finished with result: " + result);
                            if (result == 0) {
                                String amount = bundle.getString("amount", "0");
                                String authCode = bundle.getString("authCode", "123456");
                                printReceipt(amount, authCode);
                            }
                            sendStatusToFlutter(result == 0 ? "success" : "failed", "Result code: " + result);
                        }

                        // بخش 3: پاسخ دادن به SEP برای ادامه تراکنش
                        @Override
                        public void onRequestOnlineProcess(Bundle requestData) throws RemoteException {
                            Log.d(TAG, "📡 Online request sent by SEP internally. Auto-approve to continue flow.");
                            Bundle response = new Bundle();
                            response.putString("respCode", "00");     // پاسخ تأیید
                            response.putString("authCode", "123456"); // کد تأیید تستی
                            emvCoreManager.onSetOnlineResponse(response);
                        }

                        // بخش 2: گرفتن رمز کارت (PIN) از کاربر
                        @Override
                        public void onRequestInputPin(Bundle bundle) throws RemoteException {
                            Log.d(TAG, "⌨️ Requesting PIN entry...");

                            POIHsmManage hsm = POIHsmManage.getDefault();
                            String pan = bundle.getString("pan", "0000000000000000");

                            byte[] inputData = new byte[24];
                            byte[] panBytes = pan.getBytes();
                            System.arraycopy(panBytes, 0, inputData, 0, Math.min(16, panBytes.length));
                            byte[] formatData = new byte[8];
                            System.arraycopy(formatData, 0, inputData, 16, 8);

                            int result = hsm.PedGetPinBlock(
                                    POIHsmManage.PED_PINBLOCK_FETCH_MODE_DUKPT,
                                    1,
                                    POIHsmManage.PED_PINBLOCK_DUKPT_FMT_ISO9564_0_KSN_INC,
                                    60000,
                                    inputData,
                                    "06"
                            );
                            Log.d(TAG, "📥 PIN input result: " + result);
                        }
                        // بخش 4: چاپ رسید پس از موفقیت تراکنش (بدون آسیب به بخش‌های دیگر چاپ)
                        private void printReceipt(String amount, String authCode) {
                            try {
                                POIPrinterManager printer = new POIPrinterManager(context);
                                printer.open();

                                // ایجاد خطوط رسید
                                TextPrintLine title = new TextPrintLine("--- رسید پرداخت ---");
                                TextPrintLine lineAmount = new TextPrintLine("مبلغ: " + amount + " تومان");
                                TextPrintLine lineAuth = new TextPrintLine("کد تأیید: " + authCode);
                                TextPrintLine lineDate = new TextPrintLine("تاریخ: " + java.time.LocalDate.now().toString());
                                TextPrintLine lineThanks = new TextPrintLine("با تشکر از خرید شما");
                                TextPrintLine separator = new TextPrintLine("---------------------");

                                // افزودن خطوط برای چاپ
                                printer.addPrintLine(title);
                                printer.addPrintLine(lineAmount);
                                printer.addPrintLine(lineAuth);
                                printer.addPrintLine(lineDate);
                                printer.addPrintLine(lineThanks);
                                printer.addPrintLine(separator);

                                // شروع چاپ
                                printer.beginPrint(new POIPrinterManager.IPrinterListener() {
                                    @Override
                                    public void onStart() {
                                        Log.d(TAG, "🖨 شروع چاپ رسید");
                                    }

                                    @Override
                                    public void onFinish() {
                                        Log.d(TAG, "✅ چاپ رسید کامل شد");
                                        printer.close();  // آزادسازی منابع
                                    }

                                    @Override
                                    public void onError(int code, String message) {
                                        Log.e(TAG, "❌ خطا در چاپ رسید: " + code + " - " + message);
                                        printer.close();
                                    }
                                });
                                Log.d(TAG, "✅ startTransaction method has been called.");

                            } catch (Exception e) {
                                Log.e(TAG, "🖨 چاپ رسید با خطا مواجه شد: " + e.getMessage());
                            }
                        }


                        @Override public void onEmvProcess(int type, Bundle bundle) {}
                        @Override public void onSelectApplication(List<String> list, boolean isFirstSelect) throws RemoteException {
                            emvCoreManager.onSetSelectResponse(0);
                        }
                        @Override public void onConfirmCardInfo(int mode, Bundle bundle) throws RemoteException {
                            emvCoreManager.onSetCardInfoResponse(new Bundle());
                        }
                        @Override public void onKernelType(int type) {}
                        @Override public void onSecondTapCard() {}
                    });}
                catch (Exception ee) {
                    Log.e(TAG, "❗ Exception inside startTransaction: " + ee.getMessage());
                    String packageName = "com.tech.pay";
                    Intent intent = context.getPackageManager().getLaunchIntentForPackage(packageName);

                    if (intent == null) {
                        throw new Exception("TechPay app is not installed on the device");
                    }

                    intent.putExtra("amount", String.valueOf((long) amount));
                    intent.putExtra("packageName", context.getPackageName());
                    intent.putExtra("payId", orderId);      // optional, but used as payId
                    intent.putExtra("transactionType", "purchase");  // must be purchase or bill

                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intent);

                } catch (Exception e) {
                    Log.e(TAG, "💥 Exception in startPayment: " + e.getMessage());
                    Log.e(TAG, "❌ Exception while starting payment intent: " + e.getMessage());
                    sendStatusToFlutter("failed", "Exception: " + e.getMessage());
                }
            }

            private byte[] hexStringToByteArray(String s) {
                int len = s.length();
                byte[] data = new byte[len / 2];
                for (int i = 0; i < len; i += 2) {
                    data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                            + Character.digit(s.charAt(i+1), 16));
                    public void handleResultFromIntent(Intent intent) {
                        if (intent == null) {
                            sendStatusToFlutter("failed", "No data received from TechPay");
                            return;
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
                    }


                    private void sendStatusToFlutter(String status, String message) {
                        Map<String, Object> result = new HashMap<>();
                        result.put("status", status);
                        result.put("message", message);
                        channel.invokeMethod("onPaymentResult", result);
                    }
                }