# cordova-plugin-live
cordova live 直播推流插件 , 集成的是阿里云SDK


### 1.安装命令

```
cordova plugin add https://github.com/lounai-chen/cordova-plugin-live
```

### 2.使用方法
`LivePlugin.init('您的推流地址',function(s){ },function(e){alert('error: '+e)})`


### **安卓配置**

*1.注意您的cordova项目, "cordova-android" 的依赖版本起码是  10.1.2* 

*2.gradle依赖库,AndroidManifest需手动对应的修改*

## 0.AndroidManifest 


```
<application ==android:allowBackup="true"==    />

<!--      begin live-->
      
      <activity android:name="com.alivc.live.pusher.demo.MainLiveActivity"></activity>
      <activity android:alwaysRetainTaskState="true" android:name="com.alivc.live.pusher.demo.PushConfigActivity" android:screenOrientation="portrait" android:theme="@style/Theme.AppCompat.Light.NoActionBar" />
      <activity android:alwaysRetainTaskState="true" android:name="com.alivc.live.pusher.demo.PlayerActivity" android:screenOrientation="portrait" android:theme="@style/Theme.AppCompat.Light.NoActionBar" />
      <activity android:alwaysRetainTaskState="true" android:configChanges="orientation|keyboardHidden|screenSize|smallestScreenSize|screenLayout" android:name="com.alivc.live.pusher.demo.VideoRecordConfigActivity" android:screenOrientation="portrait" android:theme="@style/Theme.AppCompat.Light.NoActionBar" />
      <activity android:alwaysRetainTaskState="true" android:name="com.alivc.live.pusher.demo.LicenseActivity" android:screenOrientation="portrait" android:theme="@style/Theme.AppCompat.Light.NoActionBar" />
      <activity android:alwaysRetainTaskState="true" android:configChanges="orientation|keyboardHidden|screenSize|smallestScreenSize|screenLayout" android:name="com.alivc.live.pusher.demo.LivePushActivity" android:theme="@style/Theme.AppCompat.Light.NoActionBar" />
      <service android:enabled="true" android:foregroundServiceType="mediaProjection" android:name="com.alivc.live.pusher.demo.ForegroundService" />

      <meta-data android:name="Mob-AppKey" android:value="1aeeb15ac7a52" />
      <meta-data android:name="Mob-AppSecret" android:value="1aeeb15ac7a52" />
      
<!--      end  live-->
```

 
## 1.build.gradle (项目)

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
## 2. build.gradle (app)	

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

1.不支持模拟器调试 

2.AliyunQueenUIKit.framework,MNN.framework 设置为 Do Not Embed,  其他的framework设置为 Embed & Sign 



##### *注意:多语言配置，资源图片,不知道怎么在插件的plugin.xml文件设置.因此需要您需==手动==拷贝到对应目录* 


参考链接
阿里云官网文档: https://help.aliyun.com/document_detail/94844.html

IOS全球化多语言配置: https://www.jianshu.com/p/7232940d3e3f 
