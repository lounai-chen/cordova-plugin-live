# cordova-plugin-live
cordova live 直播推流插件 , 集成的是阿里云SDK


### 1.安装命令

```
cordova plugin add https://github.com/lounai-chen/cordova-plugin-live
```

### 2.使用方法
`LivePlugin.init('您的推流地址',function(s){ },function(e){alert('error: '+e)})`


### **安卓配置**

*1.注意您的cordova项目, "cordova-android" 的依赖版本起码是 ==10.1.2==*
*2.依赖库,AndroidManifest需手动对应的修改*

0.AndroidManifest 


```
<application android:allowBackup="true"    />

<!--      begin live-->
      <activity
        android:name="com.alivc.live.pusher.demo.MainActivity"
        android:configChanges="orientation"
        android:screenOrientation="portrait"
        android:alwaysRetainTaskState="true"
        android:clearTaskOnLaunch="false"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar"
        android:windowSoftInputMode="stateHidden|adjustPan">
        <intent-filter>
          <action android:name="android.intent.action.MAIN" />

          <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
      </activity>

      <activity
        android:name="com.alivc.live.pusher.demo.PushConfigActivity"
        android:screenOrientation="portrait"
        android:alwaysRetainTaskState="true"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar" />

      <activity
        android:name="com.alivc.live.pusher.demo.PlayerActivity"
        android:screenOrientation="portrait"
        android:alwaysRetainTaskState="true"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar" />

      <activity
        android:name="com.alivc.live.pusher.demo.VideoRecordConfigActivity"
        android:configChanges="orientation|keyboardHidden|screenSize|smallestScreenSize|screenLayout"
        android:screenOrientation="portrait"
        android:alwaysRetainTaskState="true"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar" />

      <activity
        android:name="com.alivc.live.pusher.demo.LicenseActivity"
        android:screenOrientation="portrait"
        android:alwaysRetainTaskState="true"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar" />

      <activity
        android:name="com.alivc.live.pusher.demo.LivePushActivity"
        android:alwaysRetainTaskState="true"
        android:configChanges="orientation|keyboardHidden|screenSize|smallestScreenSize|screenLayout"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar" />

      <activity
        android:name="com.mob.tools.MobUIShell"
        android:configChanges="orientation|keyboardHidden|screenSize|smallestScreenSize|screenLayout"
        android:theme="@android:style/Theme.Translucent.NoTitleBar"
        android:windowSoftInputMode="stateHidden|adjustResize">

        <intent-filter>
          <data android:scheme="tencent100371282" />
          <action android:name="android.intent.action.VIEW" />

          <category android:name="android.intent.category.BROWSABLE" />
          <category android:name="android.intent.category.DEFAULT" />
        </intent-filter>

        <!-- 调用新浪原生SDK，需要注册的回调activity -->
        <intent-filter>
          <action android:name="com.sina.weibo.sdk.action.ACTION_SDK_REQ_ACTIVITY" />
          <category android:name="android.intent.category.DEFAULT" />
        </intent-filter>

        <!--集成line客户端登录授权，需要添如下格式的过滤器-->
        <intent-filter>
          <data android:scheme="line.1477692153" />
          <action android:name="android.intent.action.VIEW" />

          <category android:name="android.intent.category.BROWSABLE" />
          <category android:name="android.intent.category.DEFAULT" />
        </intent-filter>

      </activity>

      <service
        android:name="com.alivc.live.pusher.demo.ForegroundService"
        android:enabled="true"
        android:foregroundServiceType="mediaProjection"/>

      
<!--      end  live-->
```


```
<uses-permission android:name="android.permission.CALL_PHONE" />
    <uses-feature android:name="android.hardware.telephony" android:required="false" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="com.android.vending.BILLING" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_SETTINGS" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.SYSTEM_OVERLAY_WINDOW" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.REORDER_TASKS" />
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.REORDER_TASKS" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.GET_TASKS" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.MANAGE_DOCUMENTS" />
    <uses-permission android:name="android.permission.INSTALL_PACKAGES" />
    <uses-permission android:name="android.permission.RESTART_PACKAGES" />
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```
1.build.gradle (项目)

```
allprojects {
    repositories {
        google()
        jcenter()
		
	 
      maven { url "https://maven.aliyun.com/repository/central" }
      maven { url "https://maven.aliyun.com/repository/public" }
      maven { url "https://maven.aliyun.com/repository/public" }
      maven { url "https://maven.aliyun.com/repository/google" }
}
```
2. build.gradle (app)	

```
dependencies {
  
  implementation 'com.alivc.pusher:AlivcLivePusher:4.4.1'
  implementation 'com.google.android.material:material:1.2.1'
  implementation 'androidx.constraintlayout:constraintlayout:2.0.4'
  testImplementation 'junit:junit:4.+'
  implementation 'com.acker:simplezxing:1.5'
  implementation 'com.google.code.gson:gson:2.6.2'
  implementation fileTree(include: ['commons-lang3-3.0.jar'], dir: 'src/main/commonlibs')
  implementation 'com.aliyun.animoji:animoji:1.2@aar'
  implementation 'com.aliyun.sdk.android:AliyunPlayer:5.4.4.0-full'
  implementation 'com.aliyun.sdk.android:AlivcArtc:5.4.4.0'
  implementation 'com.aliyun.rts.android:RtsSDK:2.1.0'
  implementation 'com.squareup.okhttp3:okhttp:4.8.1'

}
```


### **ios配置**

不支持模拟器调试



##### *注意:插件的文件实在太多,就没写在plugin.xml配置文件里,需==手动==拷贝到对应目录* 


参考链接
阿里云官网文档: [https://help.aliyun.com/document_detail/94844.html](https://note.youdao.com/)

IOS全球化多语言配置: https://www.jianshu.com/p/7232940d3e3f 
