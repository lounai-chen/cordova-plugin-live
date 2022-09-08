package com.aliyun.aliliveplayersdk;

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

import com.zhongzilian.chestnutapp.R;

import org.apache.cordova.CordovaActivity;

/**
 * LivePlayer调用接口Activity
 */
public class LivePlayerAPIActivity extends AppCompatActivity implements View.OnClickListener { //CordovaActivity
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

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        System.loadLibrary("RtsSDK");

        setContentView(R.layout.activity_liveplayer_api);

        initView();
        initRecyclerView();
        mController = new com.aliyun.aliliveplayersdk.LivePlayerAPIActivityController();
        mController.createAliLivePlayer(this,mSurfaceView);
    }

    private void initView(){
        mSurfaceView = findViewById(R.id.surface_view);

        mMoreImageView = findViewById(R.id.iv_more);
        mBackImageView = findViewById(R.id.iv_back);

        mStartTextView = findViewById(R.id.tv_start);
        mPauseTextView = findViewById(R.id.tv_pause);
        mResumeTextView = findViewById(R.id.tv_resume);
        mStopTextView = findViewById(R.id.tv_stop);
        mSnapShotTextView = findViewById(R.id.tv_snapshot);
        mScreenModeImageView = findViewById(R.id.iv_screen_mode);

        mEventRecyclerView = findViewById(R.id.event_recyclerview);
        mRenderFrameRecyclerView = findViewById(R.id.render_frame_recyclerview);

        mOtherViewGroup = findViewById(R.id.group_other_view);

        mStopTextView.setOnClickListener(this);
        mMoreImageView.setOnClickListener(this);
        mBackImageView.setOnClickListener(this);
        mStartTextView.setOnClickListener(this);
        mPauseTextView.setOnClickListener(this);
        mResumeTextView.setOnClickListener(this);
        mSnapShotTextView.setOnClickListener(this);
        mScreenModeImageView.setOnClickListener(this);
    }

    private void initRecyclerView(){
        mEventRecyclerView.setLayoutManager(new LinearLayoutManager(this,LinearLayoutManager.VERTICAL,false));
        mRenderFrameRecyclerView.setLayoutManager(new LinearLayoutManager(this,LinearLayoutManager.VERTICAL,false));

        mEventAdapter = new AliLivePlayerCallbackAdapter(mEventDatas);
        mRenderFrameAdapter = new AliLivePlayerCallbackAdapter(mRenderFrameDatas);

        mEventRecyclerView.setAdapter(mEventAdapter);
        mRenderFrameRecyclerView.setAdapter(mRenderFrameAdapter);
    }

    @Override
    public void onClick(View v) {
        if(v == mMoreImageView){
            showMoreDialog();
        }else if(v == mBackImageView){
            mController.onBack();
        }else if(v == mStartTextView){
            mController.start();
        }else if(v == mPauseTextView){
            mController.pause();
        }else if(v == mResumeTextView){
            mController.resume();
        }else if(v == mStopTextView){
            mController.stop();
        }else if(v == mSnapShotTextView){
            mController.snapshot();
        }else if(v == mScreenModeImageView){
            mController.changeScreenMode();
        }
    }

    private void showMoreDialog(){
        if(mMoreDialogFragment == null){
            mMoreDialogFragment = new MoreDialogFragment();
            mMoreDialogFragment.setDialogFragmentListener(new MoreDialogFragment.DialogFragmentListener() {
                @Override
                public void onVolumeChanged(float volume) {
                    mController.setVolume(volume);
                }

                @Override
                public void onMuteChanged(boolean isMute) {
                    mController.setMute(isMute);
                }

                @Override
                public void onMirrorModeChanged(MirrorMode mirrorMode) {
                    mController.setMirrorMode(mirrorMode);
                }

                @Override
                public void onScaleModeChanged(ScaleMode scaleMode) {
                    mController.setScaleMode(scaleMode);
                }

                @Override
                public void onRotateModeChanged(RotateMode rotateMode) {
                    mController.setRotateMode(rotateMode);
                }
            });
        }

        safeShowFragment(mMoreDialogFragment,"aliyun-live-player-moreDialogFragment");
    }

    private void safeShowFragment(DialogFragment dialogFragment,String tag){
        FragmentManager supportFragmentManager = getSupportFragmentManager();
        //remove fragment
        supportFragmentManager.beginTransaction().remove(dialogFragment).commit();
        //show fragment
        FragmentTransaction fragmentTransaction = supportFragmentManager.beginTransaction();
        fragmentTransaction.add(dialogFragment,tag);
        fragmentTransaction.commit();
    }

    public void showSnapShot(Bitmap image, int with, int height){
        if(mSnapShotDialogFragment == null){
            mSnapShotDialogFragment = new SnapShotDialogFragment();
        }
        mSnapShotDialogFragment.setSnapShot(image,with,height);
        safeShowFragment(mSnapShotDialogFragment,"aliyun-live-player-snapshotDialogFragment");
    }

    public void addEventItem(String item){
        mEventDatas.add(item);
        mEventAdapter.notifyItemInserted(mEventDatas.size());
        mEventRecyclerView.smoothScrollToPosition(mEventDatas.size());
    }

    public void addRenderFrameItem(String item){
        mRenderFrameDatas.add(item);
        mRenderFrameAdapter.notifyItemInserted(mRenderFrameDatas.size());
        mRenderFrameRecyclerView.smoothScrollToPosition(mRenderFrameDatas.size());
    }

    public void changeToSmallScreenMode(){
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        mOtherViewGroup.setVisibility(View.VISIBLE); 

        ViewGroup.LayoutParams layoutParams = mSurfaceView.getLayoutParams();
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
        layoutParams.height = DensityUtil.dip2px(getApplicationContext(),250);
        mSurfaceView.setLayoutParams(layoutParams);
        mSurfaceView.requestLayout();
    }

    //全屏播放
    public void changeToFullScreenMode(){
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        mOtherViewGroup.setVisibility(View.GONE);
        

        ViewGroup.LayoutParams layoutParams = mSurfaceView.getLayoutParams();
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
        layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT;
        mSurfaceView.setLayoutParams(layoutParams);
        mSurfaceView.requestLayout();
    }

    @Override
    protected void onStart() {
        super.onStart();
        mController.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
        mController.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mController.onDestroy();
    }
}
