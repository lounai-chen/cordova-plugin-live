package com.alivc.live.pusher.demo;

import android.view.SurfaceView;

import com.alivc.live.pusher.AlivcLivePusher;
import org.apache.cordova.CordovaActivity;


public interface IPushController {
   public AlivcLivePusher getLivePusher();
   public LivePushActivity.PauseState getPauseStateListener();
   public SurfaceView getPreviewView();
   //public cordovaActivity CordovaActivity();
}
