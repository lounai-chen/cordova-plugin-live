var exec = require('cordova/exec');

exports.init = function (arg0, success, error) {
    exec(success, error, 'LivePlugin', 'init', [arg0]);
};


exports.start = function (arg0, success, error) {
    exec(success, error, 'LivePlugin', 'start', [arg0]);
};