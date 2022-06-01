# cordova-plugin-live
cordova live 直播推流插件 , 集成的是阿里云SDK


### 1.安装命令

```
cordova plugin add https://github.com/lounai-chen/cordova-plugin-live
```

### 2.使用方法
`LivePlugin.init('您的推流地址',function(s){ },function(e){alert('error: '+e)})` 
```
 *   以下配置,可以让html的UI界面显示在JAVA界面的上面
 *    body {
 *       visibility: hidden;
 *       background-color: transparent;
 *     }
 *
 *     div ion-content   {
 *         visibility: visible;
 *         background-color: transparent;
 *     }

 返回的code 
 
 100|开启预览  
 101|停止预览
 102|开始推流  
 103|暂停 
 104|恢复 
 105|停止推流 
 106|重新推流成功 
 

 -10|推流未知错误  
 -11|推流SDK相关错误 
 -12|网络不稳定,稍后重试 
 -13|网络已恢复 
 -14|开始重新连接 
 -15|重新连接失败 
 -16|重新连接成功 
 -17|发送数据超时 
 -18|连接失败 
 -19|推流已断开 
 -20|推流已断开 
 -21|推流丢失数据 
 




 ``` 



### **安卓配置**

*1.注意您的cordova项目, "cordova-android" 的依赖版本起码是  10.1.2* 

*2.gradle依赖库,AndroidManifest需手动对应的修改*

## 0.AndroidManifest 


```
<application ==android:allowBackup="true"==    />

 
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

3.插件的文件夹添加成功,但xcode编译没加载进来,因此需要手动先删除再添加 




##### *注意:多语言配置，资源图片,不知道怎么在插件的plugin.xml文件设置.因此需要您需==手动==拷贝到对应目录* 
由于现在可以直接用html端的页面显示操作按钮,多语言可以不用设置了 
如果播流没声音,需要转码模版设置RTS. 详情查看 https://help.aliyun.com/document_detail/199444.html 





参考链接 

阿里云官网文档: https://help.aliyun.com/document_detail/94844.html 

IOS全球化多语言配置: https://www.jianshu.com/p/7232940d3e3f 

view置顶: https://github.com/cordova-plugin-camera-preview/cordova-plugin-camera-preview.git 


