package com.alivc.live.pusher.demo;

import android.Manifest;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.graphics.Color;
import android.hardware.Camera;
import android.net.ConnectivityManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;

import androidx.activity.ComponentActivity;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.PermissionChecker;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentController;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import androidx.viewpager.widget.ViewPager;

import com.alivc.live.pusher.AlivcAudioAACProfileEnum;
import com.alivc.live.pusher.AlivcAudioChannelEnum;
import com.alivc.live.pusher.AlivcAudioSampleRateEnum;
import com.alivc.live.pusher.AlivcEncodeModeEnum;
import com.alivc.live.pusher.AlivcFpsEnum;
import com.alivc.live.pusher.AlivcImageFormat;
import com.alivc.live.pusher.AlivcLivePushBGMListener;
import com.alivc.live.pusher.AlivcLivePushCameraTypeEnum;
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
import com.alivc.live.pusher.AlivcSoundFormat;
import com.alivc.live.pusher.SurfaceStatus;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.atomic.AtomicInteger;

import com.alivc.live.pusher.WaterMarkInfo;
import com.zhongzilian.chestnutapp.R;

import static android.os.Environment.MEDIA_MOUNTED;
import static com.alivc.live.pusher.AlivcFpsEnum.FPS_25;
import static com.alivc.live.pusher.AlivcImageFormat.IMAGE_FORMAT_YUV420P;
import static com.alivc.live.pusher.AlivcLivePushConstants.DEFAULT_VALUE_INT_AUDIO_RETRY_COUNT;
import static com.alivc.live.pusher.AlivcLivePushConstants.DEFAULT_VALUE_INT_RETRY_INTERVAL;
import static com.alivc.live.pusher.AlivcPreviewOrientationEnum.ORIENTATION_LANDSCAPE_HOME_LEFT;
import static com.alivc.live.pusher.AlivcPreviewOrientationEnum.ORIENTATION_LANDSCAPE_HOME_RIGHT;
import static com.alivc.live.pusher.AlivcPreviewOrientationEnum.ORIENTATION_PORTRAIT;

import org.apache.cordova.CordovaInterface;
import org.webrtc.utils.AlivcLog;
import org.apache.cordova.CordovaActivity;


//CordovaActivity
public class LivePushActivity extends  CordovaActivity   implements IPushController       {
    private static final String TAG = "LivePushActivity";
    private static final int FLING_MIN_DISTANCE = 50;
    private static final int FLING_MIN_VELOCITY = 0;
    private final long REFRESH_INTERVAL = 1000;
    private static final String URL_KEY = "url_key";
    private static final String ASYNC_KEY = "async_key";
    private static final String AUDIO_ONLY_KEY = "audio_only_key";
    private static final String VIDEO_ONLY_KEY = "video_only_key";
    private static final String ORIENTATION_KEY = "orientation_key";
    private static final String CAMERA_ID = "camera_id";
    private static final String FLASH_ON = "flash_on";
    private static final String AUTH_TIME = "auth_time";
    private static final String PRIVACY_KEY = "privacy_key";
    private static final String MIX_EXTERN = "mix_extern";
    private static final String MIX_MAIN = "mix_main";
    private static final String BEAUTY_CHECKED = "beauty_checked";
    private static final String FPS = "fps";
    public static final int REQ_CODE_PUSH = 0x1112;
    public static final int CAPTURE_PERMISSION_REQUEST_CODE = 0x1123;

    public SurfaceView mPreviewView;
    private ViewPager mViewPager;

    private List<android.app.Fragment> mFragmentList = new ArrayList<>();
    private FragmentAdapter mFragmentAdapter;

    private GestureDetector mDetector;
    private ScaleGestureDetector mScaleDetector;
    private LivePushFragment mLivePushFragment;
    private PushTextStatsFragment mPushTextStatsFragment;
    private PushDiagramStatsFragment mPushDiagramStatsFragment;
    private AlivcLivePushConfig mAlivcLivePushConfig;

    private AlivcLivePusher mAlivcLivePusher = null;
    private String mPushUrl = null;

    private boolean mAsync = false;
    private boolean mAudioOnly = false;
    private boolean mVideoOnly = false;
    private int mOrientation = ORIENTATION_PORTRAIT.ordinal();

    private SurfaceStatus mSurfaceStatus = SurfaceStatus.UNINITED;
//    private Handler mHandler = new Handler();
    private boolean isPause = false;
    private AlivcResolutionEnum mDefinition = AlivcResolutionEnum.RESOLUTION_540P;
    private int mCameraId = 1;// Camera.CameraInfo.CAMERA_FACING_FRONT;
    private boolean mFlash = false;
    private boolean mMixExtern = false;
    private boolean mMixMain = false;
    private boolean mBeautyOn = true;
    AlivcLivePushStatsInfo alivcLivePushStatsInfo = null;
    private String mAuthTime = "";
    private String mPrivacyKey = "";
  private ArrayList<WaterMarkInfo> waterMarkInfos = new ArrayList<>();
//    private ConnectivityChangedReceiver mChangedReceiver = new ConnectivityChangedReceiver();
    private boolean videoThreadOn = false;
    private boolean audioThreadOn = false;

    private int mNetWork = 0;
    private int mFps;
    public static CordovaInterface _this_cordova;
  public static com.alivc.live.pusher.demo.LivePlugin  _this_plugin;
    public static String _urlPlush;

  @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

      if (!permissionCheck()) {
        if (Build.VERSION.SDK_INT >= 23) {
          ActivityCompat.requestPermissions(this, permissionManifest, PERMISSION_REQUEST_CODE);
        } else {
          showNoPermissionTip(getString(noPermissionTip[mNoPermissionIndex]));
          // finish();
        }
      }



        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        addWaterMarkInfo();
        //todo
//        mPushUrl = getIntent().getStringExtra(URL_KEY);
//        mAsync = getIntent().getBooleanExtra(ASYNC_KEY, false);
//        mAudioOnly = getIntent().getBooleanExtra(AUDIO_ONLY_KEY, false);
//        mVideoOnly = getIntent().getBooleanExtra(VIDEO_ONLY_KEY, false);
//        mOrientation = getIntent().getIntExtra(ORIENTATION_KEY, ORIENTATION_PORTRAIT.ordinal());
//        mCameraId = getIntent().getIntExtra(CAMERA_ID, 1); //  1);// Camera.CameraInfo.CAMERA_FACING_FRONT
//        mFlash = getIntent().getBooleanExtra(FLASH_ON, false);
//        mAuthTime = getIntent().getStringExtra(AUTH_TIME);
//        mPrivacyKey = getIntent().getStringExtra(PRIVACY_KEY);
//        mMixExtern = getIntent().getBooleanExtra(MIX_EXTERN,false);
//        mMixMain = getIntent().getBooleanExtra(MIX_MAIN, false);
//        mBeautyOn = getIntent().getBooleanExtra(BEAUTY_CHECKED, true);
//        mFps = getIntent().getIntExtra(FPS, 0);

      mPushUrl= _urlPlush ;
      mAsync=true;
      mOrientation = 0;
      mCameraId = 1;
      mAudioOnly = false;
      mVideoOnly = false;
      mFlash = false;
      mFps = 25;
      mMixMain = false;
      mMixExtern = false;
      mBeautyOn = false; //美颜

     // LivePushActivity.startActivity(null, mAlivcLivePushConfig, mPushUrl, mAsync, mAudioOnly, mVideoOnly, mOrientation, mCameraId, mFlash, "", "", mMixMain, mAlivcLivePushConfig.isExternMainStream(), mBeautyOn, mFps); //mBeautyOn.isChecked()

//      mAlivcLivePushConfig = new AlivcLivePushConfig();
//      mAlivcLivePushConfig.setResolution(mDefinition);
//      mAlivcLivePushConfig.setExtraInfo("such_as_user_id");
//      if(mAlivcLivePushConfig.getPreviewOrientation() == AlivcPreviewOrientationEnum.ORIENTATION_LANDSCAPE_HOME_RIGHT.getOrientation() || mAlivcLivePushConfig.getPreviewOrientation() == AlivcPreviewOrientationEnum.ORIENTATION_LANDSCAPE_HOME_LEFT.getOrientation())
//      {
//        mAlivcLivePushConfig.setNetworkPoorPushImage(getFilesDir().getPath() + File.separator + "alivc_resource/poor_network_land.png");
//        mAlivcLivePushConfig.setPausePushImage(getFilesDir().getPath() + File.separator + "alivc_resource/background_push_land.png");
//      } else {
//        mAlivcLivePushConfig.setNetworkPoorPushImage(getFilesDir().getPath() + File.separator + "alivc_resource/poor_network.png");
//        mAlivcLivePushConfig.setPausePushImage(getFilesDir().getPath() + File.separator + "alivc_resource/background_push.png");
//      }
//      if(mAlivcLivePushConfig != null) {
//        mAlivcLivePushConfig.setPreviewDisplayMode(AlivcPreviewDisplayMode.ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FILL);
//      }
//      mAlivcLivePushConfig.setFps(FPS_25);
//      mAlivcLivePushConfig.setAudioOnly(false);
//      mAlivcLivePushConfig.setVideoOnly(false);
//      mAlivcLivePushConfig.setAutoFocus(true);
//      mAlivcLivePushConfig.setCameraType(AlivcLivePushCameraTypeEnum.CAMERA_TYPE_FRONT);//前置摄像头
//      mAlivcLivePushConfig.setAudioEncodeMode(AlivcEncodeModeEnum.Encode_MODE_SOFT);
//      mAlivcLivePushConfig.setVideoEncodeMode(true ? AlivcEncodeModeEnum.Encode_MODE_HARD : AlivcEncodeModeEnum.Encode_MODE_SOFT); //视频硬编码
//      mAlivcLivePushConfig.setPreviewMirror(false); //预览镜像
//      mAlivcLivePushConfig.setPushMirror(false);    //推流镜像
//      mAlivcLivePushConfig.setExternMainStream(true, AlivcImageFormat.IMAGE_FORMAT_YUVNV12, AlivcSoundFormat.SOUND_FORMAT_S16);
//      mAlivcLivePushConfig.setAudioChannels(AlivcAudioChannelEnum.AUDIO_CHANNEL_ONE);
//      mAlivcLivePushConfig.setAudioSamepleRate(AlivcAudioSampleRateEnum.AUDIO_SAMPLE_RATE_44100);
//      mAlivcLivePushConfig.setInitialVideoBitrate(1400);
//      mAlivcLivePushConfig.setAudioBitRate(1000*64);
//      mAlivcLivePushConfig.setMinVideoBitrate(600);
//      mAlivcLivePushConfig.setTargetVideoBitrate(1400);
//      mAlivcLivePushConfig.setConnectRetryCount(DEFAULT_VALUE_INT_AUDIO_RETRY_COUNT);
//      mAlivcLivePushConfig.setConnectRetryInterval(DEFAULT_VALUE_INT_RETRY_INTERVAL);
////      for(WaterMarkInfo info : waterMarkInfos){
////        mAlivcLivePushConfig.removeWaterMark(info.mWaterMarkPath);
////      }
//      mAlivcLivePushConfig.setAlivcExternMainImageFormat(IMAGE_FORMAT_YUV420P);
//      mAlivcLivePushConfig.setAudioChannels(AlivcAudioChannelEnum.AUDIO_CHANNEL_TWO);



//      mAlivcLivePushConfig  = new  AlivcLivePushConfig();//初始化推流配置类
//      mAlivcLivePushConfig.setResolution(AlivcResolutionEnum.RESOLUTION_540P);//分辨率540P，最大支持720P
//      mAlivcLivePushConfig.setFps(AlivcFpsEnum.FPS_20); //建议用户使用20fps
//      mAlivcLivePushConfig.setEnableBitrateControl(true); // 打开码率自适应，默认为true
//      mAlivcLivePushConfig.setPreviewOrientation(AlivcPreviewOrientationEnum.ORIENTATION_PORTRAIT);
//      // 默认为竖屏，可设置home键向左或向右横屏
//      mAlivcLivePushConfig.setAudioProfile(AlivcAudioAACProfileEnum.AAC_LC);//设置音频编码模式
//      mAlivcLivePushConfig.setQualityMode(AlivcQualityModeEnum.QM_FLUENCY_FIRST);//流畅度优先
//      mAlivcLivePushConfig.setEnableAutoResolution(true); // 打开分辨率自适应，默认为false
//      mAlivcLivePushConfig.setPreviewDisplayMode(AlivcPreviewDisplayMode.ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FIT);
//      if(mAlivcLivePushConfig.getPreviewOrientation() == AlivcPreviewOrientationEnum.ORIENTATION_LANDSCAPE_HOME_RIGHT.getOrientation() || mAlivcLivePushConfig.getPreviewOrientation() == AlivcPreviewOrientationEnum.ORIENTATION_LANDSCAPE_HOME_LEFT.getOrientation())
//      {
//        mAlivcLivePushConfig.setNetworkPoorPushImage(getFilesDir().getPath() + File.separator + "alivc_resource/poor_network_land.png");
//        mAlivcLivePushConfig.setPausePushImage(getFilesDir().getPath() + File.separator + "alivc_resource/background_push_land.png");
//      } else {
//        mAlivcLivePushConfig.setNetworkPoorPushImage(getFilesDir().getPath() + File.separator + "alivc_resource/poor_network.png");
//        mAlivcLivePushConfig.setPausePushImage(getFilesDir().getPath() + File.separator + "alivc_resource/background_push.png");
//      }
//
//
//        setOrientation(mOrientation);
//        setContentView(R.layout.activity_push);
//        initView();
//
//        //mAlivcLivePushConfig = (AlivcLivePushConfig) getIntent().getSerializableExtra(AlivcLivePushConfig.CONFIG);
//        mAlivcLivePusher = new AlivcLivePusher();
//
//        try {
//            mAlivcLivePusher.init(getApplicationContext(),mAlivcLivePushConfig);
//            mAlivcLivePusher.setLogLevel(AlivcLivePushLogLevel.AlivcLivePushLogLevelInfo);
//            String logPath = getFilePath(getApplicationContext(), "log_path");
//            // full log file limited was kLogMaxFileSizeInKB * 5 (parts)
//            int maxPartFileSizeInKB = 100 * 1024 * 1024; //100G
//            mAlivcLivePusher.setLogDirPath(logPath, maxPartFileSizeInKB);
//        } catch (IllegalArgumentException e) {
//            e.printStackTrace();
//            showDialog(this, e.getMessage());
//          Log.e( "error: ",  e.getMessage());
//        } catch (IllegalStateException e) {
//            e.printStackTrace();
//            showDialog(this, e.getMessage());
//          Log.e( "error: ",  e.getMessage());
//        }
//
//        mLivePushFragment = LivePushFragment.newInstance(mPushUrl, mAsync, mAudioOnly, mVideoOnly, mCameraId, mFlash, 0, mAuthTime, mPrivacyKey, mMixExtern, mMixMain, mBeautyOn, mFps, mOrientation);
//        mPushTextStatsFragment = new PushTextStatsFragment();
//        mPushDiagramStatsFragment = new PushDiagramStatsFragment();


            setOrientation(mOrientation);
        setContentView(R.layout.activity_push);
        initView();

        initViewPager();
        mScaleDetector = new ScaleGestureDetector(getApplicationContext(), mScaleGestureDetector);
         mDetector = new GestureDetector(getApplicationContext(), mGestureDetector);
        mNetWork = NetWorkUtils.getAPNType(this);




    }


    public void initView() {
        mPreviewView = (SurfaceView) findViewById(R.id.preview_view);
        mPreviewView.getHolder().addCallback(mCallback);

        //隐藏预览界面 (但内容还在)
//      mPreviewView.setVisibility(View.VISIBLE);
//      mPreviewView.bringToFront();
 // mPreviewView.setBackgroundColor(Color.TRANSPARENT);
//      mPreviewView.setBackgroundColor(0); // 设置背景色
//      mPreviewView.getBackground().setAlpha(0); // 设置填充透明度 范围：0-255

       //      _this_plugin.webView.getView().bringToFront();
     // _this_plugin.webView.getView().bringToFront();
    }

    private void initViewPager() {
        mViewPager = (ViewPager) findViewById(R.id.tv_pager);
       mFragmentList.add(mLivePushFragment); // todo




    // FragmentActivity fa = new FragmentActivity();
     // AppCompatActivity fa = new AppCompatActivity();
      //final FragmentController mFragments = FragmentController.createController(new FragmentActivity.HostCallbacks());

    //  mFragmentAdapter = new FragmentAdapter(this.getSupportFragmentManager(), mFragmentList) ; //getSupportFragmentManager
//todo


        mViewPager.setAdapter(mFragmentAdapter);
        mViewPager.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                    if (motionEvent.getPointerCount() >= 2 && mScaleDetector != null) {
                        mScaleDetector.onTouchEvent(motionEvent);
                    } else if (motionEvent.getPointerCount() == 1 && mDetector != null) {
                        mDetector.onTouchEvent(motionEvent);
                    }
//                }
                return false;
            }
        });


    }

    private void setOrientation(int orientation) {
//        if(orientation == ORIENTATION_PORTRAIT.ordinal()) {
//            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
//        } else if(orientation == ORIENTATION_LANDSCAPE_HOME_RIGHT.ordinal()) {
//            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
//        } else if(orientation == ORIENTATION_LANDSCAPE_HOME_LEFT.ordinal()) {
//            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE);
//        }
    }

    private GestureDetector.OnGestureListener mGestureDetector = new GestureDetector.OnGestureListener() {
        @Override
        public boolean onDown(MotionEvent motionEvent) {
            return false;
        }

        @Override
        public void onShowPress(MotionEvent motionEvent) {

        }

        @Override
        public boolean onSingleTapUp(MotionEvent motionEvent) {
            if (mPreviewView.getWidth() > 0 && mPreviewView.getHeight() > 0) {
                float x = motionEvent.getX() / mPreviewView.getWidth();
                float y = motionEvent.getY() / mPreviewView.getHeight();
                try{
                    mAlivcLivePusher.focusCameraAtAdjustedPoint(x, y, true);
                } catch (IllegalStateException e) {

                }
            }
            return true;
        }

        @Override
        public boolean onScroll(MotionEvent motionEvent, MotionEvent motionEvent1, float v, float v1) {
            return false;
        }

        @Override
        public void onLongPress(MotionEvent motionEvent) {

        }

        @Override
        public boolean onFling(MotionEvent motionEvent, MotionEvent motionEvent1, float v, float v1) {
            if(motionEvent == null || motionEvent1 == null) {
                return false;
            }
            if (motionEvent.getX() - motionEvent1.getX() > FLING_MIN_DISTANCE
                    && Math.abs(v) > FLING_MIN_VELOCITY) {
                // Fling left
            } else if (motionEvent1.getX() - motionEvent.getX() > FLING_MIN_DISTANCE
                    && Math.abs(v) > FLING_MIN_VELOCITY) {
                // Fling right
            }
            return false;
        }
    };

    private float scaleFactor = 1.0f;
    private ScaleGestureDetector.OnScaleGestureListener mScaleGestureDetector = new ScaleGestureDetector.OnScaleGestureListener() {
        @Override
        public boolean onScale(ScaleGestureDetector scaleGestureDetector) {
            if(scaleGestureDetector.getScaleFactor() > 1) {
                scaleFactor += 0.5;
            } else {
                scaleFactor -= 2;
            }
            if(scaleFactor <= 1) {
                scaleFactor = 1;
            }
            try{
                if(scaleFactor >= mAlivcLivePusher.getMaxZoom()) {
                    scaleFactor = mAlivcLivePusher.getMaxZoom();
                }
                mAlivcLivePusher.setZoom((int)scaleFactor);

            } catch (IllegalStateException e) {

            }
            return false;
        }

        @Override
        public boolean onScaleBegin(ScaleGestureDetector scaleGestureDetector) {
            return true;
        }

        @Override
        public void onScaleEnd(ScaleGestureDetector scaleGestureDetector) {

        }
    };

    SurfaceHolder.Callback mCallback = new SurfaceHolder.Callback() {
        @Override
        public void surfaceCreated(SurfaceHolder surfaceHolder) {
            if(mSurfaceStatus == SurfaceStatus.UNINITED) {
                mSurfaceStatus = SurfaceStatus.CREATED;
                if(mAlivcLivePusher != null) {
                    try {
                        if(mAsync) {
                            mAlivcLivePusher.startPreviewAysnc(mPreviewView);
                        } else {
                            mAlivcLivePusher.startPreview(mPreviewView);
                        }
                        if(mAlivcLivePushConfig.isExternMainStream()) {
                            startYUV(getApplicationContext());
                            startPCM(getApplicationContext());
                        }
                    } catch (IllegalArgumentException e) {
                        e.toString();
                    } catch (IllegalStateException e) {
                        e.toString();
                    }
                }
            } else if(mSurfaceStatus == SurfaceStatus.DESTROYED) {
                mSurfaceStatus = SurfaceStatus.RECREATED;
            }
        }

        @Override
        public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {
            mSurfaceStatus = SurfaceStatus.CHANGED;
        }

        @Override
        public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
            mSurfaceStatus = SurfaceStatus.DESTROYED;
        }
    };
    public static void startActivity(Activity activity, AlivcLivePushConfig alivcLivePushConfig, String url, boolean async, boolean audioOnly, boolean videoOnly, AlivcPreviewOrientationEnum orientation, int cameraId, boolean isFlash, String authTime, String privacyKey, boolean mixExtern, boolean mixMain,boolean ischecked,int fps) {
        Intent intent = new Intent(activity, LivePushActivity.class);
        Bundle bundle = new Bundle();
        bundle.putSerializable(AlivcLivePushConfig.CONFIG, alivcLivePushConfig);
        bundle.putString(URL_KEY, url);
        bundle.putBoolean(ASYNC_KEY, async);
        bundle.putBoolean(AUDIO_ONLY_KEY, audioOnly);
        bundle.putBoolean(VIDEO_ONLY_KEY, videoOnly);
        bundle.putInt(ORIENTATION_KEY, orientation.ordinal());
        bundle.putInt(CAMERA_ID, cameraId);
        bundle.putBoolean(FLASH_ON, isFlash);
        bundle.putString(AUTH_TIME, authTime);
        bundle.putString(PRIVACY_KEY, privacyKey);
        bundle.putBoolean(MIX_EXTERN, mixExtern);
        bundle.putBoolean(MIX_MAIN, mixMain);
        bundle.putBoolean(BEAUTY_CHECKED, ischecked);
        bundle.putInt(FPS, fps);
        intent.putExtras(bundle);
        activity.startActivityForResult(intent, REQ_CODE_PUSH);
     // _this_cordova.getActivity().startActivity(intent );
    }

    @Override
    protected void onResume() {
        super.onResume();
        if(mAlivcLivePusher != null) {
            try {
                if (isPause) {
                    if(mAsync) {
                        mAlivcLivePusher.resumeAsync();
                    } else {
                        mAlivcLivePusher.resume();
                    }
                    isPause = false;
                    mAlivcLivePusher.resumeBGM();
                }
            } catch (IllegalStateException e) {
                e.printStackTrace();
            } catch (IllegalArgumentException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if(mAlivcLivePusher != null) {
            try {
                if (!isPause) {
                    if (mAlivcLivePusher != null) {
                        mAlivcLivePusher.pause();
                        isPause = true;
                        mAlivcLivePusher.pauseBGM();
                    }
                }
            } catch (IllegalStateException e) {
                e.printStackTrace();
            }
        }
    }


    @Override
    public void onDestroy() {
        videoThreadOn = false;
        audioThreadOn = false;
        if(mAlivcLivePusher != null) {
            try {
                mAlivcLivePusher.destroy();
            } catch (IllegalStateException e) {
                e.printStackTrace();
            }
        }
        mFragmentList = null;
        mPreviewView = null;
        mViewPager = null;
        mFragmentAdapter = null;
        mDetector = null;
        mScaleDetector = null;
        mLivePushFragment = null;
        mPushTextStatsFragment = null;
        mPushDiagramStatsFragment = null;
        mAlivcLivePushConfig = null;
        mAlivcLivePusher = null;
        alivcLivePushStatsInfo = null;
        super.onDestroy();
    }

    public class FragmentAdapter extends FragmentPagerAdapter {

        List<Fragment> fragmentList = new ArrayList<>();
        public FragmentAdapter(FragmentManager fm, List<Fragment> fragmentList) {
            super(fm);
            this.fragmentList = fragmentList;
        }

        @Override
        public Fragment getItem(int position) {
            return fragmentList.get(position);
        }

        @Override
        public int getCount() {
            return fragmentList.size();
        }

    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        int rotation = getWindowManager().getDefaultDisplay().getRotation();
        AlivcPreviewOrientationEnum orientationEnum;
        if(mAlivcLivePusher != null) {
            switch (rotation) {
                case Surface.ROTATION_0:
                    orientationEnum = ORIENTATION_PORTRAIT;
                    break;
                case Surface.ROTATION_90:
                    orientationEnum = ORIENTATION_LANDSCAPE_HOME_RIGHT;
                    break;
                case Surface.ROTATION_270:
                    orientationEnum = ORIENTATION_LANDSCAPE_HOME_LEFT;
                    break;
                default:
                    orientationEnum = ORIENTATION_PORTRAIT;
                    break;
            }
            try {
                mAlivcLivePusher.setPreviewOrientation(orientationEnum);
            } catch (IllegalStateException e)
            {

            }
        }
    }

    @Override
    public AlivcLivePusher getLivePusher() {
        return this.mAlivcLivePusher;
    }

    @Override
    public PauseState getPauseStateListener() {
        return this.mStateListener;
    }



    @Override
    public SurfaceView getPreviewView() {
      if(mPreviewView==null){
        mPreviewView = (SurfaceView) findViewById(R.id.preview_view);
        mPreviewView.getHolder().addCallback(mCallback);
      }
        return this.mPreviewView;
    }

    private void showDialog(Context context, String message) {
      Log.e("ERROR: 123:,",message);
//        AlertDialog.Builder dialog = new AlertDialog.Builder(context);
//        dialog.setTitle(getString(R.string.dialog_title));
//        dialog.setMessage(message);
////        dialog.setNegativeButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
////            @Override
////            public void onClick(DialogInterface dialogInterface, int i) {
////                finish();
////            }
////        });
//        dialog.show();
    }

    public interface PauseState {
        void updatePause(boolean state);
    }

    private PauseState mStateListener = new PauseState() {
        @Override
        public void updatePause(boolean state) {
            isPause = state;
        }
    };

    class ConnectivityChangedReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {

            if (intent.getAction().equals(ConnectivityManager.CONNECTIVITY_ACTION)) {

                if(mNetWork != NetWorkUtils.getAPNType(context)) {
                    mNetWork = NetWorkUtils.getAPNType(context);
                    if(mAlivcLivePusher != null) {
                        if(mAlivcLivePusher.isPushing()) {
                            try {
                                mAlivcLivePusher.reconnectPushAsync(null);
                            } catch (IllegalStateException e) {
                                e.printStackTrace();
                            }
                        }
                    }
                }
            }

        }
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
                    File f = new File(getFilesDir().getPath() + File.separator+"alivc_resource/capture0.yuv");
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

    private void stopYUV() {
        videoThreadOn = false;
    }

    private void stopPcm() {
        audioThreadOn = false;
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
                    File f = new File(getFilesDir().getPath() + File.separator+"alivc_resource/441.pcm");
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

  private final int[] noPermissionTip = {
    R.string.no_camera_permission,
    R.string.no_record_bluetooth_permission,
    R.string.no_record_audio_permission,
    R.string.no_read_phone_state_permission,
    R.string.no_write_external_storage_permission,
    R.string.no_read_external_storage_permission,
  };

  private boolean permissionCheck() {
    int permissionCheck = PackageManager.PERMISSION_GRANTED;
    String permission;
    for (int i = 0; i < permissionManifest.length; i++) {
      permission = permissionManifest[i];
      mNoPermissionIndex = i;
      if (PermissionChecker.checkSelfPermission(this, permission)
        != PackageManager.PERMISSION_GRANTED) {
        permissionCheck = PackageManager.PERMISSION_DENIED;
      }
    }
    if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
      return false;
    } else {
      return true;
    }
  }

  private void showNoPermissionTip(String tip) {
    Toast.makeText(this, tip, Toast.LENGTH_LONG).show();
  }

  private void addWaterMarkInfo() {
    //添加三个水印，位置坐标不同
    WaterMarkInfo waterMarkInfo = new WaterMarkInfo();
    waterMarkInfo.mWaterMarkPath = Common.waterMark;
    WaterMarkInfo waterMarkInfo1 = new WaterMarkInfo();
    waterMarkInfo1.mWaterMarkPath = Common.waterMark;
    waterMarkInfo.mWaterMarkCoordY += 0.2;
    WaterMarkInfo waterMarkInfo2 = new WaterMarkInfo();
    waterMarkInfo2.mWaterMarkPath = Common.waterMark;
    waterMarkInfo2.mWaterMarkCoordY += 0.4;
    waterMarkInfos.add(waterMarkInfo);
    waterMarkInfos.add(waterMarkInfo1);
    waterMarkInfos.add(waterMarkInfo2);
  }

  private void showToast(final String text) {
    if (getApplicationContext() == null || text == null) {
      return;
    }
    Handler handler = new Handler(Looper.getMainLooper());
    handler.post(new Runnable() {
      @Override
      public void run() {
        if (getApplicationContext() != null) {
          Toast toast = Toast.makeText( getApplicationContext() , text, Toast.LENGTH_SHORT);
          toast.setGravity(Gravity.CENTER, 0, 0);
          toast.show();
        }
      }
    });
  }

}
