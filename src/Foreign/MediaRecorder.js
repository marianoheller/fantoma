"use strict";

exports.newMediaRecorder = function (stream) {
  return new MediaRecorder(stream);
};

exports.start = function (timeslice) {
  return function (mediaRecorder) {
    return function () {
      mediaRecorder.start(timeslice);
    };
  };
}

exports.stop = function (mediaRecorder) {
  return function () {
    mediaRecorder.stop();
  };
};

exports.state = function (mediaRecorder) {
  return mediaRecorder.state;
};


exports.requestData = function (mediaRecorder) {
  return function () {
    mediaRecorder.requestData();
  };
};

exports.onDataAvailable = function (cb) {
  return function (mediaRecorder) {
    return function () {
      mediaRecorder.ondataavailable = (blobEvent) => {
        return cb(blobEvent)();
      };
    };
  };
};