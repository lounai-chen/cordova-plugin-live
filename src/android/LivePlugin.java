package com.alivc.live.pusher.demo;

import android.content.Intent;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class LivePlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
      if (action.equals("init")) {
        String urlPush = args.getString(0);
        // Intent pIntent = new Intent(this.cordova.getActivity(), MainLiveActivity.class);
        // Intent pIntent = new Intent(this.cordova.getActivity(), PushConfigActivity.class);
        Intent pIntent = new Intent(this.cordova.getActivity(), LivePushActivity.class);
        LivePushActivity._urlPlush = urlPush;
        LivePushActivity._this_cordova = this.cordova;

        this.cordova.getActivity().startActivity(pIntent);

        // webView.getView().bringToFront(); //view置顶 //todo

        this.coolMethod("成功", callbackContext);
        return true;
      }

      return false;
    }

    private void coolMethod(String message, CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            callbackContext.success(message);
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }
}
