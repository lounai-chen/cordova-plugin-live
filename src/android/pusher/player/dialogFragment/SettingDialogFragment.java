package com.aliyun.aliliveplayersdk.dialogFragment;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;
import androidx.fragment.app.DialogFragment;

import com.huayu.quzhanyeapp.R;
import com.aliyun.aliliveplayersdk.data.AliLiveData;

public class SettingDialogFragment extends DialogFragment implements View.OnClickListener {

    private TextView mConfirmConfigTextView,mDefaultConfigTextView;
    private SwitchCompat mEnableLogSwitch,mEnableSeiSwitch,mEnableAudioVideoSwitch;
    private EditText mMaxDelayEditText,mProbeSizeEditText,mMaxBufferDurationEditText,mHighBufferDurationEditText,mStartBufferDurationEditText;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        initStyle();
        return inflater.inflate(R.layout.layout_setting_dialog_fragment, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mConfirmConfigTextView = view.findViewById(R.id.tv_confirm_config);
        mDefaultConfigTextView = view.findViewById(R.id.tv_default_config);

        mEnableLogSwitch = view.findViewById(R.id.switch_enable_log);
        mEnableSeiSwitch = view.findViewById(R.id.switch_enable_sei);
        mEnableAudioVideoSwitch = view.findViewById(R.id.switch_enable_av);

        mMaxDelayEditText = view.findViewById(R.id.et_max_delay);
        mProbeSizeEditText = view.findViewById(R.id.et_probe_size);
        mMaxBufferDurationEditText = view.findViewById(R.id.et_max_buffer);
        mHighBufferDurationEditText = view.findViewById(R.id.et_high_buffer);
        mStartBufferDurationEditText = view.findViewById(R.id.et_start_buffer);

        setDefaultData();

        mDefaultConfigTextView.setOnClickListener(this);
        mConfirmConfigTextView.setOnClickListener(this);
    }

    private void setDefaultData(){
        mEnableLogSwitch.setChecked(AliLiveData.AliLiveDefaultData.ENABLE_LOG);
        mEnableSeiSwitch.setChecked(AliLiveData.AliLiveDefaultData.ENABLE_SEI);
        mEnableAudioVideoSwitch.setChecked(AliLiveData.AliLiveDefaultData.ENABLE_RENDERFRAME);

        mMaxDelayEditText.setText(String.valueOf(AliLiveData.AliLiveDefaultData.MAX_DELAY_TIME));
        mProbeSizeEditText.setText(String.valueOf(AliLiveData.AliLiveDefaultData.MAX_PROBE_SIZE));
        mMaxBufferDurationEditText.setText(String.valueOf(AliLiveData.AliLiveDefaultData.MAX_BUFFER_DURATION));
        mHighBufferDurationEditText.setText(String.valueOf(AliLiveData.AliLiveDefaultData.HIGH_BUFFER_DURATION));
        mStartBufferDurationEditText.setText(String.valueOf(AliLiveData.AliLiveDefaultData.START_BUFFER_DURATION));
    }

    private void saveData(){
        AliLiveData.ENABLE_LOG = mEnableLogSwitch.isChecked();
        AliLiveData.LIVEPLAYER_CONFIG.enableSEI = mEnableSeiSwitch.isChecked();
        AliLiveData.LIVEPLAYER_CONFIG.enableFrameInfo = mEnableAudioVideoSwitch.isChecked();

        try {
            AliLiveData.LIVEPLAYER_CONFIG.maxDelayTime = Integer.parseInt(mMaxDelayEditText.getText().toString());
            AliLiveData.LIVEPLAYER_CONFIG.maxProbeSize = Integer.parseInt(mProbeSizeEditText.getText().toString());
            AliLiveData.LIVEPLAYER_CONFIG.maxBufferDuration = Integer.parseInt(mMaxBufferDurationEditText.getText().toString());
            AliLiveData.LIVEPLAYER_CONFIG.highBufferDuration = Integer.parseInt(mHighBufferDurationEditText.getText().toString());
            AliLiveData.LIVEPLAYER_CONFIG.startBufferDuration = Integer.parseInt(mStartBufferDurationEditText.getText().toString());
        }catch (NumberFormatException e){
            e.printStackTrace();
            Context context = getContext();
            if(context != null){
                Toast.makeText(context,  "alivc_number_format_error", Toast.LENGTH_SHORT).show();
            }
        }
    }

    private void initStyle(){
        Dialog dialog = getDialog();
        Window window;
        if(dialog != null && (window = dialog.getWindow()) != null){
            dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
            View decorView = window.getDecorView();
            decorView.setPadding(decorView.getPaddingLeft(),0,0,decorView.getPaddingBottom());
            WindowManager.LayoutParams layoutParams = window.getAttributes();
            layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
            layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT;
            layoutParams.gravity = Gravity.BOTTOM;
           // layoutParams.windowAnimations = R.style.SettingDialogAnim;
            window.setAttributes(layoutParams);
        }
    }

    @Override
    public void onClick(View v) {
        if(v == mDefaultConfigTextView){
            setDefaultData();
        }else if(v == mConfirmConfigTextView){
            saveData();
            dismiss();
        }
    }
}
