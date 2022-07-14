package com.alivc.live.pusher.demo;

import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.hardware.Camera;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.annotation.StringRes;
import androidx.fragment.app.Fragment;
import androidx.appcompat.app.AlertDialog;

import android.os.Message;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.alivc.component.custom.AlivcLivePushCustomFilter;
//import com.alivc.live.beautyui.AnimojiContainerView;
//import com.alivc.live.beautyui.bean.AnimojiItemBean;
import com.alivc.live.pusher.AlivcAudioAACProfileEnum;
import com.alivc.live.pusher.AlivcFpsEnum;
import com.alivc.live.pusher.AlivcLivePushBGMListener;
import com.alivc.live.pusher.AlivcLivePushConfig;
import com.alivc.live.pusher.AlivcLivePushError;
import com.alivc.live.pusher.AlivcLivePushErrorListener;
import com.alivc.live.pusher.AlivcLivePushInfoListener;
import com.alivc.live.pusher.AlivcLivePushLogLevel;
import com.alivc.live.pusher.AlivcLivePushNetworkListener;
import com.alivc.live.pusher.AlivcLivePushStatsInfo;
import com.alivc.live.pusher.AlivcLivePusher;
import com.alivc.live.pusher.AlivcPreviewDisplayMode;
import com.alivc.live.pusher.AlivcPreviewOrientationEnum;
import com.alivc.live.pusher.AlivcQualityModeEnum;
import com.alivc.live.pusher.AlivcResolutionEnum;
import com.alivc.live.pusher.AlivcSnapshotListener;

import org.apache.commons.lang3.concurrent.BasicThreadFactory;
import org.webrtc.utils.AlivcLog;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Vector;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.atomic.AtomicInteger;

import static android.os.Environment.MEDIA_MOUNTED;
import static com.alivc.live.pusher.AlivcLivePushCameraTypeEnum.CAMERA_TYPE_BACK;
import static com.alivc.live.pusher.AlivcLivePushCameraTypeEnum.CAMERA_TYPE_FRONT;

import com.alivc.live.pusher.SurfaceStatus;
import com.alivc.live.pusher.demo.LivePlugin;
import com.alivc.live.pusher.widget.CommonDialog;
import com.alivc.live.pusher.widget.DataView;

import com.aliyun.animoji.utils.DeviceOrientationDetector;

import com.zhongzilian.chestnutapp.R;


import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.Group;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.aliyun.aliliveplayersdk.adapter.AliLivePlayerCallbackAdapter;
import com.aliyun.aliliveplayersdk.dialogFragment.MoreDialogFragment;
import com.aliyun.aliliveplayersdk.dialogFragment.SnapShotDialogFragment;
import com.aliyun.aliliveplayersdk.util.DensityUtil;
import com.aliyun.liveplayer.define.MirrorMode;
import com.aliyun.liveplayer.define.RotateMode;
import com.aliyun.liveplayer.define.ScaleMode;

import java.util.ArrayList;
import java.util.List;


public class LivePushFragment extends android.app.Fragment implements Runnable {
  public static Context mAppContext;
  public static String mPlugin_UrlPush;
  public static String mPlugin_PreviewOrientationEnum = "1";
  public static String mPlugin_CameraIsFront = "1";
  public static String mPlugin_AudioOnly = "0";
  public static String mPlugin_VideoOnly = "0";

  //布局
  public static String mPlugin_Under = "1";   //5 是否在webview以下. 1 默认是在下方
  public static Integer mPlugin_Width = -1;   //6 窗口宽. -1 默认全屏
  public static Integer mPlugin_Height = -1;  //7 窗口高. -1 默认全屏
  public static Integer mPlugin_Left = 0;     //8 x坐标 默认0
  public static Integer mPlugin_Top = 0;      //9 y坐标 默认0

  public static String mPlugin_UrlPlayer = "";
  public static Integer mPlugin_WidthPlayer = -1;   //6 窗口宽. -1 默认全屏
  public static Integer mPlugin_HeightPlayer = -1;  //7 窗口高. -1 默认全屏的25%
  public static Integer mPlugin_LeftPlayer = 0;     //8 x坐标 默认0
  public static Integer mPlugin_TopPlayer = 0;      //9 y坐标 默认0

  public static final String TAG = "LivePushFragment";

  private static final String URL_KEY = "url_key";
  private static final String ASYNC_KEY = "async_key";
  private static final String AUDIO_ONLY_KEY = "audio_only_key";
  private static final String VIDEO_ONLY_KEY = "video_only_key";
  private static final String QUALITY_MODE_KEY = "quality_mode_key";
  private static final String CAMERA_ID = "camera_id";
  private static final String FLASH_ON = "flash_on";
  private static final String AUTH_TIME = "auth_time";
  private static final String PRIVACY_KEY = "privacy_key";
  private static final String MIX_EXTERN = "mix_extern";
  private static final String MIX_MAIN = "mix_main";
  private static final String BEAUTY_CHECKED = "beauty_checked";
  private static final String FPS = "fps";
  private static final String PREVIEW_ORIENTATION = "preview_orientation";
  private final long REFRESH_INTERVAL = 2000;

  private LinearLayout mGuide;

  private String mPushUrl = null;
  private boolean mAsync = false;

  private boolean mAudio = false;
  private boolean mVideoOnly = false;
  private boolean isPushing = false;
  private Handler mHandler = new Handler();

  private int mCameraId = Camera.CameraInfo.CAMERA_FACING_FRONT;
  private boolean isFlash = false;
  private boolean mMixExtern = false;
  private boolean mMixMain = false;
  private boolean flashState = false;

  private int snapshotCount = 0;

  private int mQualityMode = 0;

  ScheduledExecutorService mExecutorService = new ScheduledThreadPoolExecutor(5,
    new BasicThreadFactory.Builder().namingPattern("example-schedule-pool-%d").daemon(true).build());
  private boolean audioThreadOn = false;
  private boolean mIsStartAsnycPushing = false;

  private String mAuthString = "?auth_key=%1$d-%2$d-%3$d-%4$s";
  private String mMd5String = "%1$s-%2$d-%3$d-%4$d-%5$s";
  private String mTempUrl = null;
  private String mAuthTime = "";
  private String mPrivacyKey = "";
  private TextView mStatusTV;
  private LinearLayout mActionBar;
  Vector<Integer> mDynamicals = new Vector<>();


  private DataView mDataView;
  private int mCurBr;
  private int mTargetBr;
  private boolean mBeautyOn = true;
  private int mFps;
  private int mPreviewOrientation;
  private CommonDialog mDialog;
  private AlivcLivePushStatsInfo mPushStatsInfo;
  private boolean isConnectResult = false;//是否正在链接中

  private final DeviceOrientationDetector mDeviceOrientationDetector = new DeviceOrientationDetector();
  private int mDeviceOrientation = 0;
  private boolean mAnimojiOn = false;

  private AlivcLivePushConfig mAlivcLivePushConfig;
  private AlivcLivePusher mAlivcLivePusher;
  private SurfaceView mPreviewView;
  private SurfaceStatus mSurfaceStatus = SurfaceStatus.UNINITED;
  private boolean videoThreadOn = false;
  private View PageView;

//  begin player
private com.aliyun.aliliveplayersdk.LivePlayerAPIActivityController mController;

  private final List<String> mEventDatas = new ArrayList<>();
  private final List<String> mRenderFrameDatas = new ArrayList<>();

  private AliLivePlayerCallbackAdapter mEventAdapter,mRenderFrameAdapter;
  private MoreDialogFragment mMoreDialogFragment;
  private SnapShotDialogFragment mSnapShotDialogFragment;

  //开始、暂停、恢复、停止、截图
  private TextView mStartTextView,mPauseTextView,mResumeTextView,mStopTextView,mSnapShotTextView;
  private RecyclerView mEventRecyclerView, mRenderFrameRecyclerView;
  private ImageView mScreenModeImageView,mMoreImageView,mBackImageView;
  private SurfaceView mSurfaceView;
  private Group mOtherViewGroup;
//  end   player

  public static LivePushFragment newInstance(String url, boolean async, boolean mAudio, boolean mVideoOnly, int cameraId, boolean isFlash, int mode, String authTime, String privacyKey, boolean mixExtern, boolean mixMain, boolean beautyOn, int fps, int previewOrientation) {
    LivePushFragment livePushFragment = new LivePushFragment();
    Bundle bundle = new Bundle();
    bundle.putString(URL_KEY, url);
    bundle.putBoolean(ASYNC_KEY, async);
    bundle.putBoolean(AUDIO_ONLY_KEY, mAudio);
    bundle.putBoolean(VIDEO_ONLY_KEY, mVideoOnly);
    bundle.putInt(QUALITY_MODE_KEY, mode);
    bundle.putInt(CAMERA_ID, cameraId);
    bundle.putBoolean(FLASH_ON, isFlash);
    bundle.putString(AUTH_TIME, authTime);
    bundle.putString(PRIVACY_KEY, privacyKey);
    bundle.putBoolean(MIX_EXTERN, mixExtern);
    bundle.putBoolean(MIX_MAIN, mixMain);
    bundle.putBoolean(BEAUTY_CHECKED, beautyOn);
    bundle.putInt(FPS, fps);
    bundle.putInt(PREVIEW_ORIENTATION, previewOrientation);
    livePushFragment.setArguments(bundle);


    return livePushFragment;
  }

  @Override
  public void onAttach(Context context) {
    super.onAttach(context);


  }

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    //Fragment may be recreated, so move all init logic to onActivityCreated
  }



  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public void onActivityCreated(Bundle savedInstanceState) {
    super.onActivityCreated(savedInstanceState);

    mPushUrl= mPlugin_UrlPush;
    mPreviewOrientation = Integer.parseInt(mPlugin_PreviewOrientationEnum);
    mCameraId =  Integer.parseInt(mPlugin_CameraIsFront); // 1前置摄像头
    mAudio = mPlugin_AudioOnly.equals("1"); // 纯音频
    mVideoOnly = mPlugin_VideoOnly.equals("1"); //纯视频
    //mFlash = false;
    mAsync=true;
    mFps = 25;
    mMixMain = false;
    mMixExtern = false;
    mBeautyOn = false; //美颜

    mAlivcLivePushConfig  = new AlivcLivePushConfig();//初始化推流配置类
    mAlivcLivePushConfig.setResolution(AlivcResolutionEnum.RESOLUTION_540P);//分辨率540P，最大支持720P
    mAlivcLivePushConfig.setFps(AlivcFpsEnum.FPS_20); //建议用户使用20fps
    mAlivcLivePushConfig.setEnableBitrateControl(true); // 打开码率自适应，默认为true
    mAlivcLivePushConfig.setAudioOnly(mAudio);

    if(mPreviewOrientation==2){
      mAlivcLivePushConfig.setPreviewOrientation(AlivcPreviewOrientationEnum.ORIENTATION_LANDSCAPE_HOME_LEFT);
    }
    else if(mPreviewOrientation==3) {
      mAlivcLivePushConfig.setPreviewOrientation(AlivcPreviewOrientationEnum.ORIENTATION_LANDSCAPE_HOME_RIGHT);
    }
    else{
      mAlivcLivePushConfig.setPreviewOrientation(AlivcPreviewOrientationEnum.ORIENTATION_PORTRAIT);   // 默认为竖屏，可设置home键向左或向右横屏
    }
    mAlivcLivePushConfig.setAudioProfile(AlivcAudioAACProfileEnum.AAC_LC);//设置音频编码模式
    mAlivcLivePushConfig.setQualityMode(AlivcQualityModeEnum.QM_FLUENCY_FIRST);//流畅度优先
    mAlivcLivePushConfig.setEnableAutoResolution(true); // 打开分辨率自适应，默认为false
    mAlivcLivePushConfig.setPreviewDisplayMode(AlivcPreviewDisplayMode.ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FIT);

    mAlivcLivePusher    = new AlivcLivePusher();

    try {
      mAlivcLivePusher.init(mAppContext,mAlivcLivePushConfig);
      mAlivcLivePusher.setLogLevel(AlivcLivePushLogLevel.AlivcLivePushLogLevelInfo);
      String logPath = getFilePath(mAppContext, "log_path");
      // full log file limited was kLogMaxFileSizeInKB * 5 (parts)
      int maxPartFileSizeInKB = 100 * 1024 * 1024; //100G
      mAlivcLivePusher.setLogDirPath(logPath, maxPartFileSizeInKB);
    } catch (IllegalArgumentException e) {
      e.printStackTrace();
      // showDialog(this, e.getMessage());
      Log.e( "error: ",  e.getMessage());
    } catch (IllegalStateException e) {
      e.printStackTrace();
      //showDialog(this, e.getMessage());
      Log.e( "error: ",  e.getMessage());
    }


    if (mAlivcLivePusher != null) {
      mAlivcLivePusher.setLivePushInfoListener(mPushInfoListener);
      mAlivcLivePusher.setLivePushErrorListener(mPushErrorListener);
      mAlivcLivePusher.setLivePushNetworkListener(mPushNetworkListener);
      mAlivcLivePusher.setLivePushBGMListener(mPushBGMListener);
      isPushing = mAlivcLivePusher.isPushing();
    }

    mDeviceOrientationDetector.initDeviceDetector(getContext(), orientation -> {
      mDeviceOrientation = orientation;
    });

  }

  private String appResourcesPackage;

  @Override
  public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    appResourcesPackage = getActivity().getPackageName();
     PageView = inflater.inflate(R.layout.push_fragment, container, false); //inflater.inflate(getResources().getIdentifier("activity_push", "layout", appResourcesPackage), container, false);

    if(mPreviewView==null) {
      mPreviewView = (SurfaceView) PageView.findViewById(getResources().getIdentifier("frg_preview_view", "id", appResourcesPackage));
      mPreviewView.getHolder().addCallback(mCallback);
    }

    android.view.ViewGroup.LayoutParams lp = mPreviewView.getLayoutParams();
    if(mPlugin_Width == -1 || mPlugin_Height == -1) {
      lp.width =  mPreviewView.getLayoutParams().width;
      lp.height =  mPreviewView.getLayoutParams().height;
    }else {
      lp.width = mPlugin_Width;
      lp.height = mPlugin_Height;
    }
    mPreviewView.setLayoutParams(lp);
    setLayout(mPreviewView,mPlugin_Left,mPlugin_Top);

    //点击事件
    mPreviewView.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        // lp.width = 600;
        // lp.height = 600;
        // mPreviewView.setLayoutParams(lp);
        // setLayout(mPreviewView,450,650);

        LivePlugin.callJS("200|点击view");
      }
    });

    player_init(); // todo 注释

    return  PageView;
  }

  SurfaceHolder.Callback mCallback = new SurfaceHolder.Callback() {
    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder) {
      if(mSurfaceStatus == com.alivc.live.pusher.SurfaceStatus.UNINITED) {
        mSurfaceStatus = com.alivc.live.pusher.SurfaceStatus.CREATED;
        if(mAlivcLivePusher != null) {
          try {
            if(mAsync) {
              mAlivcLivePusher.startPreviewAysnc(mPreviewView);
            } else {
              mAlivcLivePusher.startPreview(mPreviewView);
            }
            if(mAlivcLivePushConfig.isExternMainStream()) {
              startYUV(mAppContext);
              startPCM(mAppContext);
            }
          } catch (IllegalArgumentException e) {
            e.toString();
          } catch (IllegalStateException e) {
            e.toString();
          }
        }
      } else if(mSurfaceStatus == com.alivc.live.pusher.SurfaceStatus.DESTROYED) {
        mSurfaceStatus = com.alivc.live.pusher.SurfaceStatus.RECREATED;
      }
    }

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {
      mSurfaceStatus = com.alivc.live.pusher.SurfaceStatus.CHANGED;
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
      mSurfaceStatus = SurfaceStatus.DESTROYED;
    }
  };

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public void onViewCreated(View view, Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);

    view.setVisibility(View.VISIBLE);
    view.bringToFront();

  }

  // begin player
  public  void player_init()
  {
    System.loadLibrary("RtsSDK");


    if(mSurfaceView==null){
      mSurfaceView = (SurfaceView) PageView.findViewById(getResources().getIdentifier("surface_view", "id", appResourcesPackage));
    }
    android.view.ViewGroup.LayoutParams lp = mSurfaceView.getLayoutParams();
    if(mPlugin_WidthPlayer == -1 || mPlugin_HeightPlayer == -1) {
      lp.width =  mSurfaceView.getLayoutParams().width;
      lp.height = Integer.parseInt( String.valueOf (mSurfaceView.getLayoutParams().height * 0.25) );
    }else {
      lp.width = mPlugin_WidthPlayer;
      lp.height = mPlugin_HeightPlayer;
    }
    mSurfaceView.setLayoutParams(lp);
    setLayout(mSurfaceView,mPlugin_LeftPlayer,mPlugin_TopPlayer);

    com.aliyun.aliliveplayersdk.data.AliLiveData.URL =  mPlugin_UrlPlayer;

    mController = new com.aliyun.aliliveplayersdk.LivePlayerAPIActivityController();
    mController.createAliLivePlayer(mAppContext,mSurfaceView);

    LivePlugin.callJS("600|初始化播放器成功");

  }

  public void PlayerStart() {
    mController.start();
  }

  public void PlayerPause() {
    mController.pause();
  }

  public void PlayerResume() {
    mController.resume();
  }

  public void PlayerStop() {
    mController.stop();
  }

  public void PlayerSnapshot() {
    mController.snapshot();
  }

  public void PlayerIsMute(boolean isMute) {
    mController.setMute(isMute);
  }

  public void PlayerSetVolume(float volume) {
    mController.setVolume(volume);
  }

  public void PlayerMirrorMode(MirrorMode mirrorMode) {
    mController.setMirrorMode(mirrorMode);
  }

  public void PlayerScaleMode(ScaleMode scaleMode) {
    mController.setScaleMode(scaleMode);
  }

  public void PlayerRotateMode(RotateMode rotateMode) {
    mController.setRotateMode(rotateMode);
  }
  // end player


  public   void StartPreview(){
    mAlivcLivePusher.startPreviewAysnc(mPreviewView);
  }

  public   void StartPushLive(){
    mAlivcLivePusher.startPushAysnc(mPushUrl);
  }

  public   void StopLive(){
    mAlivcLivePusher.stopPush();
    stopPcm();
  }

  //关闭预览
  public   void StopPreview(){
    mAlivcLivePusher.stopPreview();
  }

  //重新推流
  public   void RestartPushAync() {
    if (!mIsStartAsnycPushing) {
      mIsStartAsnycPushing = true;
      mAlivcLivePusher.restartPushAync();
    }
  }

  //暂停
  public  void Pause() {
    mAlivcLivePusher.pause();
  }

  //恢复
  public  void ResumeAsync(){
    mAlivcLivePusher.resumeAsync();
  }

  //闪光灯
  public  void LiveFlash() {
    flashState = !flashState;
    mAlivcLivePusher.setFlash(flashState);
  }

  // 摄像头 (前置/后置)
  public  void CameraDirection() {
    if (mCameraId == CAMERA_TYPE_FRONT.getCameraId()) {
      mCameraId = CAMERA_TYPE_BACK.getCameraId();
    } else {
      mCameraId = CAMERA_TYPE_FRONT.getCameraId();
    }
    mAlivcLivePusher.switchCamera();
    if(mCameraId == 0  ){ // 后置摄像头
      mAlivcLivePusher.setFlash(flashState);
    }
    else {
      mAlivcLivePusher.setFlash(false); // 关闭闪光灯
    }
  }



  AlivcLivePushInfoListener mPushInfoListener = new AlivcLivePushInfoListener() {
    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onPreviewStarted(AlivcLivePusher pusher) {
      //showToast(getSafeString(R.string.start_preview));
      LivePlugin.callJS("100|开启预览");
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onPreviewStoped(AlivcLivePusher pusher) {
      if (isAdded()) {
        //showToast(getSafeString(R.string.stop_preview));
        LivePlugin.callJS("101|停止预览");
      }
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onPushStarted(AlivcLivePusher pusher) {
      isConnectResult = true;
      mIsStartAsnycPushing = false;
      if (isAdded()) {
        //showToast(getSafeString(R.string.start_push));
        LivePlugin.callJS("102|开始推流");
      }
    }

    @Override
    public void onFirstAVFramePushed(AlivcLivePusher pusher) {
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onPushPauesed(AlivcLivePusher pusher) {
      //showToast(getSafeString(R.string.pause_push));
      LivePlugin.callJS("103|暂停");
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onPushResumed(AlivcLivePusher pusher) {
      //showToast(getSafeString(R.string.resume_push));
      LivePlugin.callJS("104|恢复");
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onPushStoped(AlivcLivePusher pusher) {
      //showToast(getSafeString(R.string.stop_push));
      LivePlugin.callJS("105|停止推流");
    }

    /**
     * 推流重启通知
     *
     * @param pusher AlivcLivePusher实例
     */
    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onPushRestarted(AlivcLivePusher pusher) {
      mIsStartAsnycPushing = false;
      //showToast(getSafeString(R.string.restart_success));
      LivePlugin.callJS("106|重新推流成功");
    }

    @Override
    public void onFirstFramePreviewed(AlivcLivePusher pusher) {

    }

    @Override
    public void onDropFrame(AlivcLivePusher pusher, int countBef, int countAft) {
    }

    @Override
    public void onAdjustBitRate(AlivcLivePusher pusher, int curBr, int targetBr) {
    }

    @Override
    public void onAdjustFps(AlivcLivePusher pusher, int curFps, int targetFps) {
    }

    @Override
    public void onPushStatistics(AlivcLivePusher pusher, AlivcLivePushStatsInfo statistics) {

    }
  };

  AlivcLivePushErrorListener mPushErrorListener = new AlivcLivePushErrorListener() {

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onSystemError(AlivcLivePusher livePusher, AlivcLivePushError error) {
      mIsStartAsnycPushing = false;
      //showDialog(getSafeString(R.string.system_error) + error.toString());
      LivePlugin.callJS("-10|推流未知错误");
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onSDKError(AlivcLivePusher livePusher, AlivcLivePushError error) {
      if (error != null) {
        mIsStartAsnycPushing = false;
        //showDialog(getSafeString(R.string.sdk_error) + error.toString());
        LivePlugin.callJS("-11|推流SDK相关错误");
      }
    }
  };

  AlivcLivePushNetworkListener mPushNetworkListener = new AlivcLivePushNetworkListener() {
    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onNetworkPoor(AlivcLivePusher pusher) {
      //showNetWorkDialog(getSafeString(R.string.network_poor));
      LivePlugin.callJS("-12|网络不稳定,稍后重试");
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onNetworkRecovery(AlivcLivePusher pusher) {
      //showToast(getSafeString(R.string.network_recovery));
      LivePlugin.callJS("-13|网络已恢复");
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onReconnectStart(AlivcLivePusher pusher) {
      //showToastShort(getSafeString(R.string.reconnect_start));
      LivePlugin.callJS("-14|开始重新连接");
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onReconnectFail(AlivcLivePusher pusher) {
      mIsStartAsnycPushing = false;
      //showDialog(getSafeString(R.string.reconnect_fail));
      LivePlugin.callJS("-15|重新连接失败");
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onReconnectSucceed(AlivcLivePusher pusher) {
     // showToast(getSafeString(R.string.reconnect_success));
      LivePlugin.callJS("-16|重新连接成功");
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onSendDataTimeout(AlivcLivePusher pusher) {
      mIsStartAsnycPushing = false;
     // showDialog(getSafeString(R.string.senddata_timeout));
      LivePlugin.callJS("-17|发送数据超时");
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onConnectFail(AlivcLivePusher pusher) {
      isConnectResult = true;
      mIsStartAsnycPushing = false;
      //showDialog(getSafeString(R.string.connect_fail));
      LivePlugin.callJS("-18|连接失败");
    }

    @Override
    public void onConnectionLost(AlivcLivePusher pusher) {
      mIsStartAsnycPushing = false;
    //  showToast("推流已断开");
      LivePlugin.callJS("-19|推流已断开");
    }

    @Override
    public String onPushURLAuthenticationOverdue(AlivcLivePusher pusher) {
      return "";
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onSendMessage(AlivcLivePusher pusher) {
      //showToast(getSafeString(R.string.send_message));
      LivePlugin.callJS("-20|推流已断开");
    }

    @Override
    public void onPacketsLost(AlivcLivePusher pusher) {
    //  showToast("推流丢包通知");
      LivePlugin.callJS("-21|推流丢失数据");
    }
  };

  private AlivcLivePushBGMListener mPushBGMListener = new AlivcLivePushBGMListener() {
    @Override
    public void onStarted() {

    }

    @Override
    public void onStoped() {

    }

    @Override
    public void onPaused() {

    }

    @Override
    public void onResumed() {

    }

    @Override
    public void onProgress(final long progress, final long duration) {
      getActivity().runOnUiThread(new Runnable() {
        @Override
        public void run() {
//          if (mMusicDialog != null) {
//            mMusicDialog.updateProgress(progress, duration);
//          }
        }
      });
    }

    @Override
    public void onCompleted() {

    }

    @Override
    public void onDownloadTimeout() {

    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onOpenFailed() {
      showDialog("打开失败");
    }
  };

  @Override
  public void onDestroy() {
    super.onDestroy();
    if (mExecutorService != null && !mExecutorService.isShutdown()) {
      mExecutorService.shutdown();
    }
  }

  private void showToast(final String text) {
    if (getActivity() == null || text == null) {
      return;
    }
    Handler handler = new Handler(Looper.getMainLooper());
    handler.post(new Runnable() {
      @Override
      public void run() {
        if (getActivity() != null) {
          Toast toast = Toast.makeText(getActivity(), text, Toast.LENGTH_SHORT);
          toast.setGravity(Gravity.CENTER, 0, 0);
          toast.show();
        }
      }
    });
  }

  private void showToastShort(final String text) {
    if (getActivity() == null || text == null) {
      return;
    }
    Handler handler = new Handler(Looper.getMainLooper());
    handler.post(new Runnable() {
      @Override
      public void run() {
        if (getActivity() != null) {
          Toast toast = Toast.makeText(getActivity(), text, Toast.LENGTH_SHORT);
          toast.setGravity(Gravity.CENTER, 0, 0);
          toast.show();
        }
      }
    });
  }

  private void showDialog(final String message) {
    if (getActivity() == null || message == null) {
      return;
    }
    if (mDialog == null || !mDialog.isShowing()) {
      Handler handler = new Handler(Looper.getMainLooper());
      handler.post(new Runnable() {
        @Override
        public void run() {
          if (getActivity() != null) {
//                        mDialog = new CommonDialog(getActivity());
//                        mDialog.setDialogTitle(getSafeString(R.string.dialog_title));
//                        mDialog.setDialogContent(message);
//                        mDialog.setConfirmButton(TextFormatUtil.getTextFormat(getActivity(), R.string.ok), new DialogInterface.OnClickListener() {
//                            @Override
//                            public void onClick(DialogInterface dialog, int which) {
//                                dialog.dismiss();
//                            }
//                        });
//                        mDialog.show();
          }
        }
      });
    }
  }

  private void showDialog(final String title, final String message) {
    if (getActivity() == null || message == null) {
      return;
    }
    Handler handler = new Handler(Looper.getMainLooper());
    handler.post(new Runnable() {
      @RequiresApi(api = Build.VERSION_CODES.M)
      @Override
      public void run() {
//        if (getActivity() != null) {
//          final AlertDialog.Builder dialog = new AlertDialog.Builder(getActivity());
//          dialog.setMessage(message);
//          dialog.setPositiveButton(getSafeString(R.string.ok), new DialogInterface.OnClickListener() {
//            @Override
//            public void onClick(DialogInterface dialogInterface, int i) {
//
//            }
//          });
//          dialog.show();
//        }
      }
    });
  }



  @Override
  public void run() {

    mHandler.postDelayed(this, REFRESH_INTERVAL);

  }

  @Override
  public void onResume() {
    super.onResume();
    mHandler.post(this);
  }

  @Override
  public void onPause() {
    super.onPause();
    mHandler.removeCallbacks(this);
  }




  private String getMD5(String string) {

    byte[] hash;

    try {
      hash = MessageDigest.getInstance("MD5").digest(string.getBytes("UTF-8"));
    } catch (NoSuchAlgorithmException e) {
      e.printStackTrace();
      return null;
    } catch (UnsupportedEncodingException e) {
      e.printStackTrace();
      return null;
    }

    StringBuilder hex = new StringBuilder(hash.length * 2);
    for (byte b : hash) {
      if ((b & 0xFF) < 0x10) {
        hex.append("0");
      }
      hex.append(Integer.toHexString(b & 0xFF));
    }

    return hex.toString();
  }

  private String getUri(String url) {
    String result = "";
    String temp = url.substring(7);
    if (temp != null && !temp.isEmpty()) {
      result = temp.substring(temp.indexOf("/"));
    }
    return result;
  }


  @RequiresApi(api = Build.VERSION_CODES.M)
  public final String getSafeString(@StringRes int resId) {
    Context context = getContext();
    if (context != null) {
      return getResources().getString(resId);
    } else {
      return "";
    }
  }



  private void stopPcm() {
    audioThreadOn = false;
  }

  public interface DynamicListern {
    void onAddDynamic();

    void onRemoveDynamic();
  }



  public static String getFilePath(Context context, String dir) {
    String logFilePath = "";
    //判断SD卡是否可用
    if (MEDIA_MOUNTED.equals(Environment.getExternalStorageState()) ) {
      logFilePath = context.getExternalFilesDir(dir).getAbsolutePath() ;
    }else{
      //没内存卡就存机身内存
      logFilePath = context.getFilesDir() + File.separator + dir;
    }
    File file = new File(logFilePath);
    if(!file.exists()){//判断文件目录是否存在
      file.mkdirs();
    }

    //Set log folder path in 4.4.0+ version
    if (false) {
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
      String logFileName = "live_pusher_" + sdf.format(new Date()) + "_" + String.valueOf(System.currentTimeMillis()) + ".log";
      logFilePath += File.separator + logFileName;
    }

    AlivcLog.d(TAG, "log filePath====>" + logFilePath);
    return logFilePath;
  }

  public void startYUV(final Context context) {
    new ScheduledThreadPoolExecutor(1, new ThreadFactory() {
      private AtomicInteger atoInteger = new AtomicInteger(0);

      public Thread newThread(Runnable r) {
        Thread t = new Thread(r);
        t.setName("LivePushActivity-readYUV-Thread"+ atoInteger.getAndIncrement());
        return t;
      }
    }).execute(new Runnable() {
      @Override
      public void run() {
        try {
          Thread.sleep(1000);
        } catch (InterruptedException e) {
          e.printStackTrace();
          AlivcLog.e(TAG, e.getMessage());
        }
        videoThreadOn = true;
        byte[] yuv;
        InputStream myInput = null;
        try {
          File f = new File(  File.separator+"alivc_resource/capture0.yuv"); //getFilesDir().getPath() +
          myInput = new FileInputStream(f);
          byte[] buffer = new byte[1280*720*3/2];
          int length = myInput.read(buffer);
          //发数据
          while(length > 0 && videoThreadOn)
          {
            long pts = System.currentTimeMillis() * 1000;
            mAlivcLivePusher.inputStreamVideoData(buffer,720,1280,720,1280*720*3/2,pts,0);
            try {
              Thread.sleep(40);
            } catch (InterruptedException e) {
              e.printStackTrace();
              AlivcLog.e(TAG, e.getMessage());
            }
            //发数据
            length = myInput.read(buffer);
            if(length <= 0)
            {
              myInput.close();
              myInput = new FileInputStream(f);
              length = myInput.read(buffer);
            }
          }
          myInput.close();
          videoThreadOn = false;
        } catch (IOException e) {
          e.printStackTrace();
          AlivcLog.e(TAG, e.getMessage());
        }
      }
    });
  }

  private void startPCM(final Context context) {
    new ScheduledThreadPoolExecutor(1, new ThreadFactory() {
      private AtomicInteger atoInteger = new AtomicInteger(0);

      @Override
      public Thread newThread(Runnable r) {
        Thread t = new Thread(r);
        t.setName("LivePushActivity-readPCM-Thread" + atoInteger.getAndIncrement());
        return t;
      }
    }).execute(new Runnable() {
      @Override
      public void run() {
        try {
          Thread.sleep(1000);
        } catch (InterruptedException e) {
          e.printStackTrace();
          AlivcLog.e(TAG, e.getMessage());
        }
        audioThreadOn = true;
        byte[] pcm;
        int allSended = 0;
        int sizePerSecond = 44100 * 2;
        InputStream myInput = null;
        OutputStream myOutput = null;
        boolean reUse = false;
        long startPts = System.nanoTime() / 1000;
        try {
          File f = new File( File.separator+"alivc_resource/441.pcm");  //getFilesDir().getPath() +
          myInput = new FileInputStream(f);
          // File f = new File("/sdcard/alivc_resource/441.pcm");
          byte[] buffer = new byte[2048];
          int length = myInput.read(buffer, 0, 2048);
          double sleep_time = 1000/44.1;
          while (length > 0 && audioThreadOn) {
            long start = System.nanoTime();
            long pts = System.currentTimeMillis() * 1000;
            mAlivcLivePusher.inputStreamAudioData(buffer, length, 44100, 1, pts);
            allSended += length;
            if ((allSended * 1000000L / sizePerSecond - 50000) > (pts - startPts)) {
              try {
                Thread.sleep(45);
              } catch (InterruptedException e) {
                e.printStackTrace();
              }
            }
            length = myInput.read(buffer);
            if (length < 2048) {
              myInput.close();
              myInput = new FileInputStream(f);
              length = myInput.read(buffer);
            }
            long end = System.nanoTime();
            try {
              long real_sleep_time = (long)(sleep_time - (end - start) / 1000 / 1000);
              Thread.sleep(real_sleep_time);
            } catch (InterruptedException e) {
              e.printStackTrace();
              AlivcLog.e(TAG, e.getMessage());
            }
          }
          myInput.close();
          audioThreadOn = false;
        } catch (IOException e) {
          e.printStackTrace();
          AlivcLog.e(TAG, e.getMessage());
        }
      }
    });
  }

  /*
   * 设置控件所在的位置XY，并且不改变宽高，
   * XY为绝对位置
   */
  public static void setLayout(View view,int x,int y)
  {
    ViewGroup.MarginLayoutParams margin= new ViewGroup.MarginLayoutParams(view.getLayoutParams());
    //margin.setMargins(x,y, x+margin.width, y+margin.height);
    margin.setMargins(x,y, 0, 0);
    RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(margin);
    view.setLayoutParams(layoutParams);
  }

}
