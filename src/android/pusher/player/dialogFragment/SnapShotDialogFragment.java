package com.aliyun.aliliveplayersdk.dialogFragment;

import android.app.Dialog;
import android.graphics.Bitmap;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.zhongzilian.chestnutapp.R;

public class SnapShotDialogFragment extends DialogFragment {

    private static final String TAG = "SnapShotDialogFragment";

    private Bitmap mSnapShotBitmap;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        initStyle();
        return inflater.inflate(R.layout.layout_snapshot_dialog_fragment, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ImageView mSnapshotImageView = view.findViewById(R.id.iv_snapshot);
        mSnapshotImageView.setImageBitmap(mSnapShotBitmap);
    }

    private void initStyle(){
        Dialog dialog = getDialog();
        Window window;
        if(dialog != null && (window = dialog.getWindow()) != null){
            dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
            WindowManager.LayoutParams layoutParams = window.getAttributes();
            layoutParams.gravity = Gravity.TOP | Gravity.START;
            //layoutParams.windowAnimations = R.style.SnapshotDialogAnim;
            window.setAttributes(layoutParams);
            window.setBackgroundDrawable(new ColorDrawable());
        }
    }

    public void setSnapShot(Bitmap image, int with, int height){
        this.mSnapShotBitmap = image;
    }
}
