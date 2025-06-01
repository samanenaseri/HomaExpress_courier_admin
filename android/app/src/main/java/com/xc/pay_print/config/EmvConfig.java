package com.xc.pay_print.config;

import com.pos.sdk.emvcore.PosEmvAid;
import com.pos.sdk.emvcore.PosEmvCapk;
import com.pos.sdk.emvcore.POIEmvCoreManager;

public class EmvConfig {

    public static void loadDefaultAidAndCapk() {
        POIEmvCoreManager emvCoreManager = POIEmvCoreManager.getDefault();

        // === AID ===
        PosEmvAid aid = new PosEmvAid();
        aid.AID = hexToBytes("A0000005591010");
        aid.FloorLimit = 10000;
        aid.TargetPercentage = 100;
        aid.MaxTargetPercentage = 0;
        aid.TACOnline = hexToBytes("DC4004F800");
        aid.TACDefault = hexToBytes("DC4000A800");
        aid.TACDenial = hexToBytes("0010000000");
        aid.SelectIndicator = true;

        emvCoreManager.EmvSetAid(aid);

        // === CAPK ===
        PosEmvCapk capk = new PosEmvCapk();
        capk.RID = hexToBytes("A000000559");
        capk.CapkIndex = (byte) 0x01;
        capk.Exponent = hexToBytes("03");
        capk.Module = hexToBytes("C2E89C438B2B3E845E0F6D323FE0B0A3");// باید مقدار کامل صحیح از PSP بگیری
        capk.Checksum = new byte[20]; // یا یک مقدار تستی مثل: hexToBytes("A1B2C3A1B2C3A1B2C3A1B2C3A1B2C3A1")
        capk.AlgorithmInd = PosEmvCapk.ALGO_IND_RSA;
        capk.HashInd = PosEmvCapk.HASH_IND_SHA1;

        emvCoreManager.EmvSetCapk(capk);
    }

    private static byte[] hexToBytes(String hex) {
        int len = hex.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hex.charAt(i), 16) << 4)
                    + Character.digit(hex.charAt(i+1), 16));
        }
        return data;
    }

}
