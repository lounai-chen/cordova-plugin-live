# cordova-plugin-live
cordova live 直播推流 , 直播播流 , 集成的是阿里云SDK


### 1.安装命令

```
cordova plugin add https://github.com/lounai-chen/cordova-plugin-live
```

### 2.使用方法
``` 
//0 推流URL地址
//1 是否竖屏. 1是竖屏,2横屏朝home键,3横屏朝不朝home键
//2 是否前置摄像头. 1是
//3 纯音频
//4 纯视频
//5 是否在webview以下. 1 默认是在下方
//6 窗口宽. -1 默认全屏
//7 窗口高. -1 默认全屏
//8 x坐标 默认0
//9 y坐标 默认0      

  liveInit(){
    //初始化推流
      var th = this;
      const bodyEl:any = window.document.querySelector("#myBody"); 
      bodyEl.style.visibility = 'hidden'
      bodyEl.style.background = "transparent"   
      LivePlugin.init("rtmp://rtmp.您的推流地址",
        '1','1','0','0','1','600','600','450,'650',
        function(t){ 
          alert('ok: '+t);
          th.liveStatus = t;    
          // to do sth
        },
        function(e){alert('error: '+e)}
      )
  } 





//0 播流URL地址
//1 窗口宽. -1 默认全屏
//2 窗口高. -1 默认全屏的25%
//3 x坐标 默认0
//4 y坐标 默认0 

  PlayerInit(){
    //初始化播放器
    var th = this;
    const bodyEl:any = window.document.querySelector("#myBody"); 
    bodyEl.style.visibility = 'hidden'
    bodyEl.style.background = "transparent"  
    LivePlugin.InitPlayer(
      'artc://alibo.您的播流地址',
       '-1','-1', '0' , '50' ,
       function(t){ 
        alert('ok: '+t);
        th.liveStatus = t;   
        // to do sth
      },
      function(e){alert('error: '+e)}
    );
  }


 
``` 

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

 200|点击view   //5 是否在webview以下. 默认是在下方: true [备注;该参数为0,也就是在webview上方才生效]


 600|初始化播放器成功 
 601|播放异常 errorCode:   , errorMsg:    [备注;当停止推流|没有网络,也会触发该回调,errorCode:537067524]
 

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

*0.申请推流SDK License证书,如果您在安装之前没修改plugin.xml证书的值,则要修改 platforms/android/android.json中licensekey,licensefile的值. 参考https://help.aliyun.com/document_detail/431730.html* 

*1.注意您的cordova项目, "cordova-android" 的依赖版本起码是  10.1.2* 

*2. AndroidManifest需手动对应的修改*

*3. 插件下的src/android/res/layout的布局文件 需手动拷贝到对应的目录* 

```
<application android:allowBackup="true"   />

 
```

 


### **ios配置**

1.不支持模拟器调试  
 

2.推荐 Pod集成 

		2.1 编辑 ios/podfile 文件,加入配置. 可参考 demo\Podfile 文件 

		2.2 在IOS目录,执行 pod install 

		2.3 拷贝内容 ios/Pods/Target Support Files/Pods-appname/pods-appname.debug.xconfig 

		2.4 粘贴到 ios/pods-debug.xcconfig 

		2.5 同理操作release配置文件 

    2.6 添加SDK库: AliLivePlayerSDK.framework , opencv2.framework , queen.framework 设置为 Embed & Sign 

    2.7 资源文件里面的 AlivcLiveReplayKitDefine.h 

    2.8 添加SDK授权文件,并且在xcode的info菜单加对应的key(AlivcLicenseKey,AlivcLicenseFile) 参考 https://help.aliyun.com/document_detail/431730.htm 


 



3.插件的文件夹添加成功,但xcode编译没加载进来,因此需要手动先删除再添加(先添加文件夹,再Add Files to) (记得一定要勾选 Copy Items if needed) 


4.*注意:资源图片,需要您需手动拷贝到对应目录* 



### 其他问题 
1.如果播流没声音,需要转码模版设置RTS. 详情查看 https://help.aliyun.com/document_detail/199444.html 

2.纯音频功能,播放时是没有声音,请参考https://help.aliyun.com/document_detail/86458.html   
 
  
  


### 参考链接 

阿里云官网文档;  
 推流: https://help.aliyun.com/document_detail/94844.html ,  
 播流: https://help.aliyun.com/document_detail/404871.htm 


IOS全球化多语言配置: https://www.jianshu.com/p/7232940d3e3f 

view置顶: https://github.com/cordova-plugin-camera-preview/cordova-plugin-camera-preview.git  

 
   

![avatar](/demo/picture/1.jpg)


