# cordova-plugin-live
cordova live 直播推流插件, 支持多个用户连麦 , 集成的是阿里云SDK


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

 200|点击view   //5 是否在webview以下. 默认是在下方: true [该参数为0,也就是在webview上方才生效]


 600|初始化播放器成功 
 

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

*2. AndroidManifest需手动对应的修改*

```
<application android:allowBackup="true"   />

 
```

 


### **ios配置**

1.不支持模拟器调试 

2.AliyunQueenUIKit.framework,MNN.framework 设置为 Do Not Embed,  其他的framework设置为 Embed & Sign 

3.插件的文件夹添加成功,但xcode编译没加载进来,因此需要手动先删除再添加 

4.*注意:多语言配置，资源图片,不知道怎么在插件的plugin.xml文件设置.因此需要您需手动拷贝到对应目录* 

5.由于现在可以直接用html端的页面显示操作按钮,多语言可以不用设置了 

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


