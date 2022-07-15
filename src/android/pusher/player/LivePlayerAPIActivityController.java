package com.aliyun.aliliveplayersdk;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;
import android.view.SurfaceView;

import com.alivc.live.pusher.demo.LivePlugin;
import com.aliyun.aliliveplayersdk.data.AliLiveData;
import com.aliyun.aliliveplayersdk.data.AliLiveScreenMode;
import com.aliyun.liveplayer.AliLivePlayer;
import com.aliyun.liveplayer.AliLivePlayerFactory;
import com.aliyun.liveplayer.AliLivePlayerObserver;
import com.aliyun.liveplayer.define.ErrorCode;
import com.aliyun.liveplayer.define.ErrorInfo;
import com.aliyun.liveplayer.define.FrameInfo;
import com.aliyun.liveplayer.define.InfoBean;
import com.aliyun.liveplayer.define.InfoCode;
import com.aliyun.liveplayer.define.MirrorMode;
import com.aliyun.liveplayer.define.RotateMode;
import com.aliyun.liveplayer.define.ScaleMode;

public class LivePlayerAPIActivityController {

    private static final String TAG = "LivePlayerAPIActivityCo";

   // private final com.aliyun.aliliveplayersdk.LivePlayerAPIActivity mLivePlayerAPIActivity;
    private AliLiveScreenMode mCurrentScreenMode = AliLiveScreenMode.Small;
    private AliLivePlayer mAliLivePlayer;
    private boolean mHasPlayed = false;

   // public LivePlayerAPIActivityController(com.aliyun.aliliveplayersdk.LivePlayerAPIActivity livePlayerAPIActivity){
      //  this.mLivePlayerAPIActivity = livePlayerAPIActivity;
   // }

  public LivePlayerAPIActivityController( ){

  }


    public  void createAliLivePlayer(Context context, SurfaceView surfaceView){
        mAliLivePlayer = AliLivePlayerFactory.createAliLivePlayer(context.getApplicationContext(), AliLiveData.ENABLE_LOG);
        mAliLivePlayer.setRenderView(surfaceView);
        mAliLivePlayer.setConfig(AliLiveData.LIVEPLAYER_CONFIG);
        mAliLivePlayer.setObserver(new AliLivePlayerObserver() {
            @Override
            public void onError(AliLivePlayer player, ErrorInfo errorInfo) {
                super.onError(player, errorInfo);
                mHasPlayed = false;
                String str = "<font color='#ff0000'>" +
                        "OnError ==> errorCode:" +
                        errorInfo.getCode() +
                        " , errorMsg:" +
                        errorInfo.getMsg() +
                        "</font>";
              //  mLivePlayerAPIActivity.addEventItem(str);

                if (errorInfo.getCode() == ErrorCode.ERROR_GENERAL_EIO.getValue()) {
                    //When occurs network error, start again
                    start();
                }

                LivePlugin.callJS("601|播放异常 errorCode:" +
                errorInfo.getCode() +
                " , errorMsg:" +
                errorInfo.getMsg() );
            }

            @Override
            public void onRenderingStart(AliLivePlayer player) {
                super.onRenderingStart(player);
                mHasPlayed = true;
               // mLivePlayerAPIActivity.addEventItem("OnRenderingStart");
            }

            @Override
            public void onInfo(AliLivePlayer player, InfoBean info) {
                super.onInfo(player, info);
                if(info.getCode() == InfoCode.AutoPlayStart.getValue()){
                 //   mLivePlayerAPIActivity.addEventItem("AutoPlayStart");
                }else if(info.getCode() == InfoCode.SwitchToSoftwareVideoDecoder.getValue()){
                //    mLivePlayerAPIActivity.addEventItem("SwitchToSoftwareVideoDecoder");
                }else if(info.getCode() == InfoCode.CurrentDownloadSpeed.getValue()){
//                    mLivePlayerAPIActivity.addEventItem("<font color='#ff00ff'>CurrentDownloadSpeed(bps):"+info.getExtraValue()+"</font>");
                    Log.e(TAG, "onInfo: CurrentDownloadSpeed = " + info.getExtraValue());
                }
            }

            @Override
            public void onVideoSizeChanged(AliLivePlayer player, int width, int height) {
                super.onVideoSizeChanged(player, width, height);
               // mLivePlayerAPIActivity.addEventItem("VideoSize: width="+width+" , height="+height);
            }

            @Override
            public void onSnapShot(AliLivePlayer player, Bitmap image, int with, int height) {
                super.onSnapShot(player, image, with, height);
               // mLivePlayerAPIActivity.showSnapShot(image,with,height);
            }

            @Override
            public boolean onRenderFrame(AliLivePlayer player, FrameInfo frameInfo) {
                int frameType = frameInfo.frameType;
                String str;
                if(frameType == FrameInfo.FrameType_audio){
                    //audio
                    str = "<font color='#0000ff'> audio ==> audio_format:" + frameInfo.audio_format
                            + " , audio_channels:" + frameInfo.audio_channels
                            + " , audio_sample_rate:" + frameInfo.audio_sample_rate
                            + " , audio_data_size:" + (frameInfo.video_data == null ? "0" : frameInfo.video_data.length)
                            + "</font>";
                }else{
                    //video
                    str = "<font color='#ff0000'> video ==> video_format:" + frameInfo.video_format
                            + " , video_width:" + frameInfo.video_width
                            + " , video_height:" + frameInfo.video_height
                            + " , video_data_siz:" + (frameInfo.video_data == null ? "0" : frameInfo.video_data)
                            + "</font>";
                }
//                mLivePlayerAPIActivity.runOnUiThread(new Runnable() {
//                    @Override
//                    public void run() {
//                        mLivePlayerAPIActivity.addRenderFrameItem(str);
//                    }
//                });

                return super.onRenderFrame(player, frameInfo);
            }

            @Override
            public void onSeiData(AliLivePlayer player, int type, byte[] data) {
                super.onSeiData(player, type, data);
                String str = "<font color='#0000ff'>" +
                        "SEI ==> type:" +
                        type +
                        " , data:" +
                        new String(data);
               // mLivePlayerAPIActivity.addEventItem(str);
            }
        });
    }

    public void changeScreenMode() {
        if(mCurrentScreenMode == AliLiveScreenMode.Small){
          //  mLivePlayerAPIActivity.changeToFullScreenMode();
            mCurrentScreenMode = AliLiveScreenMode.Full;
        }else{
          //  mLivePlayerAPIActivity.changeToSmallScreenMode();
            mCurrentScreenMode = AliLiveScreenMode.Small;
        }
    }

    public void onBack() {
        if(mCurrentScreenMode == AliLiveScreenMode.Small){
          //  mLivePlayerAPIActivity.finish();
        }else{
            changeScreenMode();
        }
    }

    public void onDestroy(){
        AliLivePlayerFactory.releaseAliLivePlayer(mAliLivePlayer);
    }

    public void onStop() {
        if(!AliLiveData.ENABLE_BACKGROUND_PLAY && mHasPlayed){
            mAliLivePlayer.stop();
        }
    }

    public void onStart() {
        if(!AliLiveData.ENABLE_BACKGROUND_PLAY && mHasPlayed){
            start();
        }
    }

    public void start() {
        mAliLivePlayer.start(AliLiveData.URL);
    }

    public void pause() {
        mAliLivePlayer.pause();
    }

    public void resume() {
        mAliLivePlayer.resume();
    }

    public void stop(){
        mAliLivePlayer.stop();
        mHasPlayed = false;
    }

    public void snapshot() {
        mAliLivePlayer.snapshot();
    }

    public void setVolume(float volume) {
        mAliLivePlayer.setVolume(volume);
    }

    public void setMute(boolean isMute) {
        mAliLivePlayer.setMute(isMute);
    }

    public boolean isMute(){
        return mAliLivePlayer.isMute();
    }

    public void setMirrorMode(MirrorMode mirrorMode) {
        mAliLivePlayer.setMirrorMode(mirrorMode);
    }

    public void setScaleMode(ScaleMode scaleMode) {
        mAliLivePlayer.setScaleMode(scaleMode);
    }

    public void setRotateMode(RotateMode rotateMode) {
        mAliLivePlayer.setRotateMode(rotateMode);
    }
}
