package com.alivc.live.pusher.demo.bean;
//import com.alivc.live.pusher.demo.R;
import com.huayu.quzhanyeapp.R;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class Constants {
    private static List<String> live_push_button;
    private static List<String> live_pull_button;
    private static List<String> live_play_button;
    private static List<BeautyItemData> live_beauty_skin_name;

    private static HashMap<String,Integer> live_img_soure;

    public static HashMap<String,Integer> getLive_img_soure() {
        return live_img_soure;
    }
    static {
        /**
         * push页面的按钮
         * */
        live_push_button = new ArrayList<>();
        live_img_soure=new HashMap<>();
 
        live_push_button.add("开始推流");
        live_push_button.add("美颜");
        live_push_button.add("音效");
        live_push_button.add("静音");
        live_push_button.add("摄像头");
        live_push_button.add("调节参数");
        live_push_button.add("数据指标");

        /**
         * pull页面按钮
         */
        live_pull_button = new ArrayList<>();
        live_pull_button.add("暂停观看");
        live_pull_button.add("静音");
        live_pull_button.add("听筒切换");
 

        /**
         * play页面按钮
         */
        live_play_button = new ArrayList<>();
        live_play_button.add("暂停观看");

        /**
         * beauty页面的美肌
         * */
        live_beauty_skin_name = new ArrayList<>();
        live_beauty_skin_name.add(new BeautyItemData("磨皮",false,60));
    }
    public static List<String> getPushActivityButtonList(){
        return live_push_button;
    }
    public static List<String> getPullActivityButtonList(){
        return live_pull_button;
    }
    public static List<String> getPlayActivityButtonList(){
        return live_play_button;
    }
    public static List<BeautyItemData> getBeautySkinNameList(){
        return live_beauty_skin_name;
    }
}
