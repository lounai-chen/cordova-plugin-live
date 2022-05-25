var exec = require('cordova/exec');

exports.init = function (arg0, success, error) {
    exec(success, error, 'LivePlugin', 'init', [arg0]);
};

exports.preview = function ( success, error) {
    exec(success, error, 'LivePlugin', 'preview', []);
};

exports.start = function ( success, error) {
    exec(success, error, 'LivePlugin', 'start', []);
};

exports.stop = function ( success, error) {
    exec(success, error, 'LivePlugin', 'stop', []);
};

 