"use strict"

exports._getUserMedia = function (constraints) {
  return function () {
    if (!navigator || !navigator.mediaDevices)
      return Promise.reject("No navigator");
    return navigator.mediaDevices.getUserMedia(constraints);
  };
};