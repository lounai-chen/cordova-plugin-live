package com.alivc.live.pusher.demo;

import android.app.Activity;
import android.os.Bundle;
import androidx.annotation.Nullable;
import android.view.View;
import android.widget.ImageView;

//import com.alivc.live.pusher.demo.R;
import com.zhongzilian.chestnutapp.R;
import org.apache.cordova.CordovaActivity;

public class LicenseActivity extends CordovaActivity {

    private ImageView mBack;
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_license);
        mBack = (ImageView) findViewById(R.id.iv_back);
        mBack.setOnClickListener(mListener);
    }

    View.OnClickListener mListener = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            int id = view.getId();
            switch (id) {
                case R.id.iv_back:
                    finish();
                    break;
            }
        }
    };
}
