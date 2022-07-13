package com.aliyun.aliliveplayersdk.data;

import com.aliyun.liveplayer.define.AliLivePlayerConfig;

public class AliLiveData {

    public static AliLivePlayerConfig LIVEPLAYER_CONFIG = new AliLivePlayerConfig();

    /**
     * 默认值
     */
    public static class AliLiveDefaultData{
        public static boolean ENABLE_LOG = true;
        public static boolean ENABLE_BACKGROUND_PLAY = false;
        public static boolean ENABLE_SEI = LIVEPLAYER_CONFIG.enableSEI;
        public static boolean ENABLE_RENDERFRAME = LIVEPLAYER_CONFIG.enableFrameInfo;
        public static int MAX_DELAY_TIME = LIVEPLAYER_CONFIG.maxDelayTime;
        public static int MAX_BUFFER_DURATION = LIVEPLAYER_CONFIG.maxBufferDuration;
        public static int HIGH_BUFFER_DURATION = LIVEPLAYER_CONFIG.highBufferDuration;
        public static int START_BUFFER_DURATION = LIVEPLAYER_CONFIG.startBufferDuration;
        public static int MAX_PROBE_SIZE = LIVEPLAYER_CONFIG.maxProbeSize;
    }

    public static String URL = "";
    public static boolean ENABLE_LOG = AliLiveDefaultData.ENABLE_LOG;
    public static boolean ENABLE_BACKGROUND_PLAY = AliLiveDefaultData.ENABLE_BACKGROUND_PLAY;

}
