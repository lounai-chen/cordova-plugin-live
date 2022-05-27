var exec = require('cordova/exec');

//0 推流URL地址
//1 是否竖屏. 1是竖屏,2横屏朝home键,3横屏朝不朝home键
//2 是否前置摄像头. 1是
//3 纯音频
//4 纯视频
exports.init = function (arg0,arg1,arg2,arg3,arg4, success, error) {
    cordova.require('cordova/channel').onCordovaReady.subscribe(function(){
        exec(success, error, 'LivePlugin', 'init', [arg0,arg1,arg2,arg3,arg4]);
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