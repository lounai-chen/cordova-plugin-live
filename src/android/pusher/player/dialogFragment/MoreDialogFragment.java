package com.aliyun.aliliveplayersdk.dialogFragment;

import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.CompoundButton;
import android.widget.SeekBar;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentActivity;

import com.zhongzilian.chestnutapp.R;
import com.aliyun.aliliveplayersdk.data.AliLiveData;
import com.aliyun.liveplayer.define.MirrorMode;
import com.aliyun.liveplayer.define.RotateMode;
import com.aliyun.liveplayer.define.ScaleMode;

public class MoreDialogFragment extends DialogFragment implements CompoundButton.OnCheckedChangeListener {

    private SwitchCompat mMuteSwitch,mEnableBackgroundPlaySwitch;
    private String[] mScaleModeArray,mRotateModeArray,mMirrorModeArray;
    private Spinner mScaleModeSpinner,mMirrorModeSpinner,mRotateModeSpinner;
    private ArrayAdapter<String> mScaleModeArrayAdapter,mRotateModeArrayAdapter,mMirrorModeArrayAdapter;
    private TextView mVolumeTextView;
    private SeekBar mVolumeSeekBar;

    private DialogFragmentListener mDialogFragmentListener;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {


      // mScaleModeArray = new String[]("11","22","33"); //getResources().getStringArray(R.array.spinner_scale_mode);
       //mRotateModeArray = getResources().getStringArray(R.array.spinner_rotate_mode);
        //mMirrorModeArray = getResources().getStringArray(R.array.spinner_mirror_mode);

        mScaleModeArrayAdapter = new ArrayAdapter<>(getContext(),R.layout.item_spinner_adapter, mScaleModeArray);
        mScaleModeArrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        mRotateModeArrayAdapter = new ArrayAdapter<>(getContext(),R.layout.item_spinner_adapter,mRotateModeArray);
        mRotateModeArrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        mMirrorModeArrayAdapter = new ArrayAdapter<>(getContext(),R.layout.item_spinner_adapter,mMirrorModeArray);
        mMirrorModeArrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        return inflater.inflate(R.layout.layout_more_dialog_fragment, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        mMuteSwitch = view.findViewById(R.id.switch_mute);
        mEnableBackgroundPlaySwitch = view.findViewById(R.id.switch_background_play);
        mScaleModeSpinner = view.findViewById(R.id.spinner_scale_mode);
        mMirrorModeSpinner = view.findViewById(R.id.spinner_mirror_mode);
        mRotateModeSpinner = view.findViewById(R.id.spinner_rotate_mode);

        mVolumeTextView = view.findViewById(R.id.tv_volume);
        mVolumeTextView.setText("1");

        mVolumeSeekBar = view.findViewById(R.id.seekbar_volume);

        initSpinnerAdapter();
        initListener();
        super.onViewCreated(view, savedInstanceState);
    }

    private void initSpinnerAdapter(){
        mScaleModeSpinner.setAdapter(mScaleModeArrayAdapter);
        mMirrorModeSpinner.setAdapter(mMirrorModeArrayAdapter);
        mRotateModeSpinner.setAdapter(mRotateModeArrayAdapter);
    }

    private void initListener(){
        mMuteSwitch.setOnCheckedChangeListener(this);
        mEnableBackgroundPlaySwitch.setOnCheckedChangeListener(this);

        mMirrorModeSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                MirrorMode mirrorMode = MirrorMode.MIRROR_MODE_NONE;
                switch (mMirrorModeArray[position]){
                    case "MIRROR_NONE":
                        mirrorMode = MirrorMode.MIRROR_MODE_NONE;
                        break;
                    case "MIRROR_HORIZONTAL":
                        mirrorMode = MirrorMode.MIRROR_MODE_HORIZONTAL;
                        break;
                    case "MIRROR_VERTICAL":
                        mirrorMode = MirrorMode.MIRROR_MODE_VERTICAL;
                        break;
                }
                if(mDialogFragmentListener != null){
                    mDialogFragmentListener.onMirrorModeChanged(mirrorMode);
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) { }
        });

        mScaleModeSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                ScaleMode scaleMode = ScaleMode.SCALE_ASPECT_FIT;
                switch (mScaleModeArray[position]){
                    case "SCALE_ASPECT_FIT":
                        scaleMode = ScaleMode.SCALE_ASPECT_FIT;
                        break;
                    case "SCALE_ASPECT_FILL":
                        scaleMode = ScaleMode.SCALE_ASPECT_FILL;
                        break;
                    case "SCALE_TO_FILL":
                        scaleMode = ScaleMode.SCALE_TO_FILL;
                        break;
                }
                if(mDialogFragmentListener != null){
                    mDialogFragmentListener.onScaleModeChanged(scaleMode);
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) { }
        });

        mRotateModeSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                RotateMode rotateMode = RotateMode.ROTATE_0;
                switch (mRotateModeArray[position]){
                    case "ROTATE_0":
                        rotateMode = RotateMode.ROTATE_0;
                        break;
                    case "ROTATE_90":
                        rotateMode = RotateMode.ROTATE_90;
                        break;
                    case "ROTATE_180":
                        rotateMode = RotateMode.ROTATE_180;
                        break;
                    case "ROTATE_270":
                        rotateMode = RotateMode.ROTATE_270;
                        break;
                }
                if(mDialogFragmentListener != null){
                    mDialogFragmentListener.onRotateModeChanged(rotateMode);
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) { }
        });

        mVolumeSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if(fromUser && mDialogFragmentListener != null){
                    float volume = progress / 100.0f;
                    mVolumeTextView.setText("100");
                    mDialogFragmentListener.onVolumeChanged(volume);
                }
            }
            @Override
            public void onStartTrackingTouch(SeekBar seekBar) { }
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) { }
        });
    }

    @Override
    public void onStart() {
        super.onStart();
        DisplayMetrics dm = new DisplayMetrics();
        FragmentActivity activity = getActivity();
        if(activity != null){
            activity.getWindowManager().getDefaultDisplay().getMetrics(dm);
        }
        Dialog dialog = getDialog();
        if(dialog != null){
            dialog.getWindow().setLayout(dm.widthPixels, getDialog().getWindow().getAttributes().height);
            dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    public void setDialogFragmentListener(DialogFragmentListener listener){
        this.mDialogFragmentListener = listener;
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if(buttonView == mMuteSwitch){
            if(mDialogFragmentListener != null){
                mDialogFragmentListener.onMuteChanged(isChecked);
            }
        }else if(buttonView == mEnableBackgroundPlaySwitch){
            AliLiveData.ENABLE_BACKGROUND_PLAY = isChecked;
        }
    }

    public interface DialogFragmentListener {
        void onVolumeChanged(float volume);
        void onMuteChanged(boolean isMute);
        void onMirrorModeChanged(MirrorMode mirrorMode);
        void onScaleModeChanged(ScaleMode scaleMode);
        void onRotateModeChanged(RotateMode rotateMode);
    }
}
