package com.aliyun.aliliveplayersdk;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.huayu.quzhanyeapp.R;

import com.aliyun.aliliveplayersdk.data.AliLiveData;
import com.aliyun.aliliveplayersdk.dialogFragment.SettingDialogFragment;
//import com.google.zxing.activity.CaptureActivity;

public class MainPlayerActivity extends AppCompatActivity implements View.OnClickListener {

    private com.aliyun.aliliveplayersdk.MainActivityController mController;

    private EditText mUrlEditText;
    private TextView mStartPlayTextView;
    private ImageView mQRCodeImageView;
    private ImageView mConfigImageView;
    private SettingDialogFragment mSettingDialogFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_live_main);

       // mController = new com.aliyun.aliliveplayersdk.MainActivityController(this);
        initView();
    }

    private void initView(){
        mUrlEditText = findViewById(R.id.et_url);
        mConfigImageView = findViewById(R.id.iv_config);
        mQRCodeImageView = findViewById(R.id.iv_qrcode);
        mStartPlayTextView = findViewById(R.id.tv_start_play);

        mQRCodeImageView.setOnClickListener(this);
        mConfigImageView.setOnClickListener(this);
        mStartPlayTextView.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if(v == mQRCodeImageView){
            mController.startQRCode();
        }else if(v == mStartPlayTextView){
            mController.openPlayActivity(mUrlEditText.getText().toString());
        }else if(v == mConfigImageView){
            if(mSettingDialogFragment == null){
                mSettingDialogFragment = new SettingDialogFragment();
            }
            safeShowFragment(mSettingDialogFragment,"aliyun-live-player-settingDialogFragment");
        }
    }

    private void safeShowFragment(DialogFragment dialogFragment, String tag){
        FragmentManager supportFragmentManager = getSupportFragmentManager();
        //remove fragment
        supportFragmentManager.beginTransaction().remove(dialogFragment).commit();
        //show fragment
        FragmentTransaction fragmentTransaction = supportFragmentManager.beginTransaction();
        fragmentTransaction.add(dialogFragment,tag);
        fragmentTransaction.commit();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
//        if (requestCode == CaptureActivity.REQ_CODE) {
//            mController.onRequestPermissionResult(grantResults);
//        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        mController.onActivityResult(requestCode,resultCode,data);
    }

    public void qrScanningSuccess(String stringExtra) {
        mUrlEditText.setText(stringExtra);
    }

    public void openActivity(Class clz){
        Intent intent = new Intent(MainPlayerActivity.this,clz);
        startActivity(intent);
    }

    public void openActivityForResult(Class clz,int requestCode){
        Intent intent = new Intent(MainPlayerActivity.this,clz);
        startActivityForResult(intent,requestCode);
    }

    public void showToast(String msg){
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
    }

}
