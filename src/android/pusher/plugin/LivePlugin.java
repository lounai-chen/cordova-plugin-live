package com.alivc.live.pusher.demo;

import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.app.PendingIntent;
import android.content.Intent;
import android.graphics.Color;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;

import com.alivc.live.pusher.demo.LivePushActivity;
import com.alivc.live.pusher.demo.LivePushFragment;
import com.plugin.floatv1.floatingwindow.FloatingVideoService;


import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;



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

  public LivePlugin(){
    super();
  }


  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    if (action.equals("init")) {
      String urlPush = args.getString(0);

      LivePushFragment.mUrlPush = urlPush;
      LivePushFragment.mAppContext = this.cordova.getContext();
      initLive(callbackContext);

      this.coolMethod("成功", callbackContext);
      return true;
    }
    //预览
    else if (action.equals("preview")) {
      if(fragment_live == null){
        callbackContext.error("请先初始化");
        return false;
      }
      previewLive(callbackContext);

      this.coolMethod("成功", callbackContext);
      return true;
    }
    //开启直播
    else if (action.equals("start")) {
      if(fragment_live == null){
        callbackContext.error("请先初始化");
        return false;
      }

      fragment_live.StartPushLive();
      this.coolMethod("成功", callbackContext);
      return true;
    }
    //停止直播
    else if (action.equals("stop")) {
      if(fragment_live == null){
        callbackContext.error("请先初始化");
        return false;
      }

      fragment_live.StopLive();
      this.stopLiveView(callbackContext);
      this.coolMethod("成功", callbackContext);
      return true;
    }
    else if (action.equals("init_old")) {

      String urlPush = args.getString(0);
      // Intent pIntent = new Intent(this.cordova.getActivity(), MainLiveActivity.class);
      // Intent pIntent = new Intent(this.cordova.getActivity(), PushConfigActivity.class);
      Intent pIntent = new Intent(this.cordova.getActivity(), LivePushActivity.class);
      // Intent notificationIntent = new Intent(this.cordova.getActivity(), LivePushActivity.class);
      LivePushActivity._urlPlush = urlPush;
      LivePushActivity._this_cordova = this.cordova;
      LivePushActivity._this_plugin = this;

      this.cordova.getActivity().startActivity(pIntent);

      this.coolMethod("成功", callbackContext);
      return true;
    }

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

        // If parents do not match look for.
        if(curParent.getParent() != rootParent) {
          while(curParent != null && curParent.getParent() != rootParent) {
            curParent = curParent.getParent();
          }

          if(curParent != null) {
            ((ViewGroup)curParent).setBackgroundColor(0x00000000);
            ((ViewGroup)curParent).bringToFront();
          } else {
            // Do default...
            curParent = view.getParent();
            webViewParent = curParent;
            ((ViewGroup)view).bringToFront();
          }
        }else{
          // Default
          webViewParent = curParent;
          ((ViewGroup)curParent).bringToFront();
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



  private void coolMethod(String message, CallbackContext callbackContext) {
    if (message != null && message.length() > 0) {
      callbackContext.success(message);
    } else {
      callbackContext.error("Expected one non-empty string argument.");
    }
  }


}
