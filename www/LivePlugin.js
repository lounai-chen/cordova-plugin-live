var exec = require('cordova/exec');

//////// begin live push 直播推流 ///////

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
exports.init = function (arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9, success, error) {
    cordova.require('cordova/channel').onCordovaReady.subscribe(function(){
        exec(success, error, 'LivePlugin', 'init', [arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9]);
    });
};

//开启预览
exports.preview = function ( success, error) {
    exec(success, error, 'LivePlugin', 'preview', []);
};

//开启推流
exports.start = function ( success, error) {
    exec(success, error, 'LivePlugin', 'start', []);
};

//停止推流
exports.stop = function ( success, error) {
    exec(success, error, 'LivePlugin', 'stop', []);
};

 // 摄像头 (前置/后置)
 exports.CameraDirection = function ( success, error) {
    exec(success, error, 'LivePlugin', 'CameraDirection', []);
};


// 闪光灯
exports.LiveFlash = function ( success, error) {
    exec(success, error, 'LivePlugin', 'LiveFlash', []);
};

//暂停
exports.Pause = function ( success, error) {
    exec(success, error, 'LivePlugin', 'Pause', []);
};

//恢复
exports.ResumeAsync = function ( success, error) {
    exec(success, error, 'LivePlugin', 'ResumeAsync', []);
};

//重新推流
exports.RestartPushAync = function ( success, error) {
    exec(success, error, 'LivePlugin', 'RestartPushAync', []);
};

//关闭预览
exports.StopPreview = function ( success, error) {
    exec(success, error, 'LivePlugin', 'StopPreview', []);
};

//////// end live push 直播推流 ///////




//////// begin player 播放器 ///////

// 初始化播放器
//0 播流URL地址
//1 窗口宽. -1 默认全屏
//2 窗口高. -1 默认全屏的25%
//3 x坐标 默认0
//4 y坐标 默认0
exports.InitPlayer = function (arg0,arg1,arg2,arg3,arg4 , success, error) {
    cordova.require('cordova/channel').onCordovaReady.subscribe(function(){
        exec(success, error, 'LivePlugin', 'InitPlayer', [arg0,arg1,arg2,arg3,arg4]);
    });
};

//开启播放
exports.PlayerStart = function ( success, error) {
    exec(success, error, 'LivePlugin', 'PlayerStart', []);
};


//暂停播放
exports.PlayerPause = function ( success, error) {
    exec(success, error, 'LivePlugin', 'PlayerPause', []);
};


//恢复播放
exports.PlayerResume = function ( success, error) {
    exec(success, error, 'LivePlugin', 'PlayerResume', []);
};

//停止播放
exports.PlayerStop = function ( success, error) {
    exec(success, error, 'LivePlugin', 'PlayerStop', []);
};

//播放器截图
exports.PlayerSnapshot = function ( success, error) {
    exec(success, error, 'LivePlugin', 'PlayerSnapshot', []);
};


//是否静音 1静音
exports.PlayerIsMute = function (arg0, success, error) {
    exec(success, error, 'LivePlugin', 'PlayerIsMute', [arg0]);
};

//设置播放器音量
//arg0 音量大小
exports.PlayerSetVolume = function ( arg0, success, error) {
    exec(success, error, 'LivePlugin', 'PlayerSetVolume', [arg0]);
};

//
exports.PlayerMirrorMode = function (  arg0,success, error) {
    exec(success, error, 'LivePlugin', 'PlayerMirrorMode', [arg0]);
};


exports.PlayerScaleMode = function ( arg0, success, error) {
    exec(success, error, 'LivePlugin', 'PlayerScaleMode', [arg0]);
};


exports.PlayerRotateMode = function ( arg0, success, error) {
    exec(success, error, 'LivePlugin', 'PlayerRotateMode', [arg0]);
};

//重新设置播放器位置大小
exports.SetPlayerLayout = function ( arg0, arg1, arg2, arg3, success, error) {
    exec(success, error, 'LivePlugin', 'SetPlayerLayout', [arg0,arg1, arg2, arg3]);
};


//////// end player ///////