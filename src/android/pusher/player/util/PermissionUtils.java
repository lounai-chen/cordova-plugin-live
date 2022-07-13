package com.aliyun.aliliveplayersdk.util;

import android.content.Context;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

public class PermissionUtils {

    public static boolean checkPermissionGranted(@NonNull Context context, @NonNull String permission){
        return ContextCompat.checkSelfPermission(context,permission) != PackageManager.PERMISSION_GRANTED;
    }

    public static boolean permissionRequestResultGranted(int[] grantResults){
        return grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
    }

}
