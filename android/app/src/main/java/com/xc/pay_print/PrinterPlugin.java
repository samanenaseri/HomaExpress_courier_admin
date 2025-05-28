package com.xc.pay_print;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.ArrayList;

public class PrinterPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private PrinterManager printerManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "com.xc.pay_print/printer");
        channel.setMethodCallHandler(this);
        printerManager = new PrinterManager(binding.getApplicationContext());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "printReceipt":
                ArrayList<String> lines = call.argument("lines");
                if (lines != null) {
                    printerManager.printReceipt(lines.toArray(new String[0]));
                    result.success(true);
                } else {
                    result.error("INVALID_ARGUMENTS", "Lines cannot be null", null);
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
} 