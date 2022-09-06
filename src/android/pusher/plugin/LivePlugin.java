package com.alivc.live.pusher.demo;

import android.Manifest;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.core.content.PermissionChecker;

import com.aliyun.liveplayer.define.MirrorMode;
import com.aliyun.liveplayer.define.RotateMode;
import com.aliyun.liveplayer.define.ScaleMode;
import com.zhongzilian.chestnutapp.R;


import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;


/**
 * 直播推流: 以下配置,可以让html的UI界面显示在JAVA界面的上面
 *    body{
 *       visibility: hidden;
 *       background-color: transparent;
 *     }
 *
 *     div {
 *         visibility: visible;
 *     }
 */
public class LivePlugin extends CordovaPlugin   {



  private  LivePushFragment  fragment_live;

  private int containerViewId = 20; //<- set to random number to prevent conflict with other plugins
  private ViewParent webViewParent;
  private static CallbackContext mCallbackContext;

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
  }

  public LivePlugin(){
    super();
  }

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    //////// begin live push 直播推流 ///////
    if (action.equals("init")) {

      mCallbackContext = callbackContext;    //拿到回调对象并保存
      if(initPermissionCheck() == false){
        return  false;
      }

      LivePushFragment.mPlugin_UrlPush = args.getString(0);                 //0 推流URL地址
      LivePushFragment.mPlugin_PreviewOrientationEnum = args.getString(1);  //1 是否竖屏. 1是竖屏,2横屏朝home键,3横屏朝不朝home键
      LivePushFragment.mPlugin_CameraIsFront = args.getString(2);           //2 是否前置摄像头. 1是
      LivePushFragment.mPlugin_AudioOnly  = args.getString(3);              //3 纯音频
      LivePushFragment.mPlugin_VideoOnly = args.getString(4);               //4 纯视频
      LivePushFragment.mPlugin_Under = args.getString(5);                   //5 是否在webview以下. 1 默认是在下方
      LivePushFragment.mPlugin_Width = Integer.parseInt(args.getString(6)); //6 窗口宽. -1 默认全屏
      LivePushFragment.mPlugin_Height = Integer.parseInt(args.getString(7));//7 窗口高. -1 默认全屏
      LivePushFragment.mPlugin_Left = Integer.parseInt(args.getString(8));  //8 x坐标 默认0
      LivePushFragment.mPlugin_Top = Integer.parseInt(args.getString(9));   //9 y坐标 默认0

      LivePushFragment.mPlugin_IsJustPlayer = 1; //需要播放器碎片布局

      LivePushFragment.mAppContext = this.cordova.getContext();
      initLive(callbackContext);
      //todo 不锁屏
      return true;
    }
    //开启预览
    else if (action.equals("preview")) {
      if(fragment_live == null){
        callbackContext.error("1|请先初始化");
        return false;
      }
      previewLive(callbackContext);
      this.coolMethod("成功", callbackContext);
      return true;
    }
    //开启直播
    else if (action.equals("start")) {
      if(fragment_live == null){
        callbackContext.error("1|请先初始化");
        return false;
      }
      fragment_live.StartPushLive();

      this.coolMethod("成功", callbackContext);
      return true;
    }
    //停止直播
    else if (action.equals("stop")) {
      if(fragment_live == null){
        callbackContext.error("1|请先初始化");
        return false;
      }
      fragment_live.StopLive();
      this.stopLiveView(callbackContext);
      this.coolMethod("成功", callbackContext);
      return true;
    }
    // 摄像头 (前置/后置)
    else if (action.equals("CameraDirection")) {
      if(fragment_live == null){
        callbackContext.error("1|请先初始化");
        return false;
      }
      fragment_live.CameraDirection();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    // 闪光灯
    else if (action.equals("LiveFlash")) {
      if(fragment_live == null){
        callbackContext.error("1|请先初始化");
        return false;
      }
      fragment_live.LiveFlash();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    //暂停
    else if (action.equals("Pause")) {
      if(fragment_live == null){
        callbackContext.error("1|请先初始化");
        return false;
      }
      fragment_live.Pause();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    //恢复
    else if (action.equals("ResumeAsync")) {
      if(fragment_live == null){
        callbackContext.error("1|请先初始化");
        return false;
      }
      fragment_live.ResumeAsync();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    //重新推流
    else if (action.equals("RestartPushAync")) {
      if(fragment_live == null){
        callbackContext.error("1|请先初始化");
        return false;
      }
      fragment_live.RestartPushAync();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    //关闭预览
    else if (action.equals("StopPreview")) {
      if(fragment_live == null){
        callbackContext.error("1|请先初始化");
        return false;
      }
      fragment_live.StopPreview();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    //////// end live push 直播推流 ///////

    //////// begin player 播放器 ///////
    //初始化播放器
    else if (action.equals("InitPlayer")){
      mCallbackContext = callbackContext;    //拿到回调对象并保存
      if(initPermissionCheck() == false){
        return  false;
      }

      LivePushFragment.mPlugin_UrlPlayer = args.getString(0);                 //0  播流URL地址
      LivePushFragment.mPlugin_WidthPlayer = Integer.parseInt(args.getString(1)); //1 窗口宽. -1 默认全屏
      LivePushFragment.mPlugin_HeightPlayer = Integer.parseInt(args.getString(2));//2 窗口高. -1  默认全屏的25%
      LivePushFragment.mPlugin_LeftPlayer = Integer.parseInt(args.getString(3));  //3 x坐标 默认0
      LivePushFragment.mPlugin_TopPlayer = Integer.parseInt(args.getString(4));   //4 y坐标 默认0


      if (fragment_live == null) {
        if(LivePushFragment.mPlugin_IsJustPlayer==0){
          LivePushFragment.mPlugin_IsJustPlayer = 1; //需要播放器碎片布局
        }
        LivePushFragment.mAppContext = this.cordova.getContext();
        initLive(callbackContext);
      }
      else {
        LivePushFragment.mPlugin_IsJustPlayer = 0;
        cordova.getActivity().runOnUiThread(new Runnable() {
          @Override
          public void run() {
            fragment_live.player_init();
          }
        });
      }
      return true;
    }
    else if (action.equals("PlayerStart")){
      fragment_live.PlayerStart();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("PlayerPause")){
      fragment_live.PlayerPause();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("PlayerResume")){
      fragment_live.PlayerResume();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("PlayerStop")){
      fragment_live.PlayerStop();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("PlayerSnapshot")){
      fragment_live.PlayerSnapshot();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("PlayerIsMute")){
      boolean b = args.getString(0).equals("1");
      fragment_live.PlayerIsMute(b);
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("PlayerSetVolume")){
      Float f = Float.parseFloat(args.getString(0));
      fragment_live.PlayerSetVolume(f);
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("PlayerMirrorMode")){
      MirrorMode mirrorMode = MirrorMode.MIRROR_MODE_HORIZONTAL; // todo
      fragment_live.PlayerMirrorMode(mirrorMode);
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("PlayerScaleMode")){
      ScaleMode scaleMode = ScaleMode.SCALE_TO_FILL; // todo
      fragment_live.PlayerScaleMode(scaleMode);
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("PlayerRotateMode")){
      RotateMode rotateMode = RotateMode.ROTATE_90; // todo
      fragment_live.PlayerRotateMode(rotateMode);
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("SetPlayerLayout")){
      fragment_live.mPlugin_HeightPlayer = Integer.parseInt(args.getString(0));
      fragment_live.mPlugin_WidthPlayer = Integer.parseInt(args.getString(1));
      fragment_live.mPlugin_LeftPlayer = Integer.parseInt(args.getString(2));
      fragment_live.mPlugin_TopPlayer = Integer.parseInt(args.getString(3));
      cordova.getActivity().runOnUiThread(new Runnable() {
        @Override
        public void run() {
          fragment_live.SetPlayerLayout();
        }
      });

      this.coolMethod("重新设置播放器位置大小成功", callbackContext);
      return true;
    }

    //////// end player ///////


    return false;
  }



  private boolean stopLiveView(CallbackContext callbackContext) {
    if(webViewParent != null) {
      cordova.getActivity().runOnUiThread(new Runnable() {
        @Override
        public void run() {
          ((ViewGroup)webView.getView()).bringToFront();
          webViewParent = null;
        }
      });
    }

    if(this.hasView(callbackContext) == false){
      return true;
    }

    FragmentManager fragmentManager = cordova.getActivity().getFragmentManager();
    FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
    fragmentTransaction.remove(fragment_live);
    fragmentTransaction.commit();
    fragment_live = null;

    callbackContext.success();
    return true;
  }

  private boolean hasView(CallbackContext callbackContext) {
    if(fragment_live == null) {
      callbackContext.error("No preview");
      return false;
    }

    return true;
  }

  private boolean previewLive(CallbackContext callbackContext) {
    cordova.getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        fragment_live.StartPreview();
      }

      });

    return true;
  }


  private boolean initLive(CallbackContext callbackContext) {

    if (fragment_live != null) {
      callbackContext.error("fragment_live already started");
      return true;
    }

    fragment_live = new LivePushFragment();

    cordova.getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {

        //create or update the layout params for the container view
        FrameLayout containerView = (FrameLayout)cordova.getActivity().findViewById(containerViewId);
        if(containerView == null){
          containerView = new FrameLayout(cordova.getActivity().getApplicationContext());
          containerView.setId(containerViewId);

          FrameLayout.LayoutParams containerLayoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
          cordova.getActivity().addContentView(containerView, containerLayoutParams);
        }

        //display camera below the webview

        View view = webView.getView();
        ViewParent rootParent = containerView.getParent();
        ViewParent curParent = view.getParent();

        view.setBackgroundColor(0x00000000);

        //5 是否在webview以下. 1 默认是在下方
        if(LivePushFragment.mPlugin_Under.equals("1")) {
          // If parents do not match look for.
          if (curParent.getParent() != rootParent) {
            while (curParent != null && curParent.getParent() != rootParent) {
              curParent = curParent.getParent();
            }

            if (curParent != null) {
              ((ViewGroup) curParent).setBackgroundColor(0x00000000);
              ((ViewGroup) curParent).bringToFront();
            } else {
              // Do default...
              curParent = view.getParent();
              webViewParent = curParent;
              ((ViewGroup) view).bringToFront();
            }
          } else {
            // Default
            webViewParent = curParent;
            ((ViewGroup) curParent).bringToFront();
          }
        }

        //add the fragment to the container
        FragmentManager fragmentManager = cordova.getActivity().getFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.add(containerView.getId(), fragment_live);
        fragmentTransaction.commit();
      }
    });

    return true;
  }

  public static void callJS(String message) {
    if (mCallbackContext != null) {
      PluginResult dataResult = new PluginResult(PluginResult.Status.OK, message);
      dataResult.setKeepCallback(true);// 非常重要
      mCallbackContext.sendPluginResult(dataResult);
    }
  }



  private void coolMethod(String message, CallbackContext callbackContext) {
    if (message != null && message.length() > 0) {
      callbackContext.success(message);
    } else {
      callbackContext.error("Expected one non-empty string argument.");
    }
  }

  private boolean  initPermissionCheck()
  {
    if (!permissionCheck()) {
      if (Build.VERSION.SDK_INT >= 23) {
        ActivityCompat.requestPermissions(this.cordova.getActivity(), permissionManifest, PERMISSION_REQUEST_CODE);
      } else {
        mCallbackContext.error("0|请授权");
        return false;
      }
    }
    return  true;
  }

  private int mNoPermissionIndex = 0;
  private final int PERMISSION_REQUEST_CODE = 1;
  private final String[] permissionManifest = {
    Manifest.permission.CAMERA,
    Manifest.permission.BLUETOOTH,
    Manifest.permission.RECORD_AUDIO,
    Manifest.permission.READ_PHONE_STATE,
    Manifest.permission.WRITE_EXTERNAL_STORAGE,
    Manifest.permission.READ_EXTERNAL_STORAGE,
    Manifest.permission.INTERNET,
  };



  private boolean permissionCheck() {
    int permissionCheck = PackageManager.PERMISSION_GRANTED;
    String permission;
    for (int i = 0; i < permissionManifest.length; i++) {
      permission = permissionManifest[i];
      mNoPermissionIndex = i;
      if (PermissionChecker.checkSelfPermission(this.cordova.getContext(), permission)
        != PermissionChecker.PERMISSION_DENIED) {
        permissionCheck = PackageManager.PERMISSION_DENIED;
      }
    }
    if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
      return false;
    } else {
      return true;
    }
  }

//  private void showNoPermissionTip(String tip) {
//    Toast.makeText(this, tip, Toast.LENGTH_LONG).show();
//  }


}
