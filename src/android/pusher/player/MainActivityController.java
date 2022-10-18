package com.aliyun.aliliveplayersdk;

import android.Manifest;
import android.content.Intent;

import androidx.core.app.ActivityCompat;

import com.acker.simplezxing.activity.CaptureActivity;
import com.aliyun.aliliveplayersdk.data.AliLiveData;
import com.aliyun.aliliveplayersdk.util.PermissionUtils;
import com.huayu.livestream.MainActivity;
//import com.google.zxing.activity.CaptureActivity;

import com.huayu.quzhanyeapp.R;

// todo 删除
public class MainActivityController {

    private final MainActivity mMainActivity;

    public MainActivityController(MainActivity mainActivity){
        this.mMainActivity = mainActivity;
    }

    /**
     * QR code scanning
     */
    public void startQRCode() {
//        if(PermissionUtils.checkPermissionGranted(mMainActivity, Manifest.permission.CAMERA)){
//            ActivityCompat.requestPermissions(mMainActivity,new String[] {Manifest.permission.CAMERA}, CaptureActivity.REQ_CODE);
//        }else{
//            mMainActivity.openActivityForResult(CaptureActivity.class,CaptureActivity.REQ_CODE);
//        }
    }

    /**
     * permission result
     */
    public void onRequestPermissionResult(int[] grantResults) {
//        if(PermissionUtils.permissionRequestResultGranted(grantResults)){
//            mMainActivity.openActivityForResult(CaptureActivity.class,CaptureActivity.REQ_CODE);
//        }else{
//            mMainActivity.showToast( "alivc_agree_camera_permission");
//        }
    }

    /**
     * activity result
     */
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        //QR Code
        if(requestCode == CaptureActivity.REQ_CODE){
            if(resultCode == com.aliyun.aliliveplayersdk.MainPlayerActivity.RESULT_OK){
              //  mMainActivity.qrScanningSuccess(data.getStringExtra(CaptureActivity.INTENT_EXTRA_KEY_QR_SCAN));
            }
        }
    }

    public void openPlayActivity(String url) {
        AliLiveData.URL = url;
        final String strUtl = AliLiveData.URL.toLowerCase();
        if (strUtl.startsWith("artc://")) {
            System.loadLibrary("RtsSDK");
        }
       // mMainActivity.openActivity(com.aliyun.aliliveplayersdk.LivePlayerAPIActivity.class);
    }
}
