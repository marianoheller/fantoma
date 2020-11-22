"use strict";

// TODO: improve this function
exports._fromBlobs = function (blobs) {
  try {
    return new Blob(blobs, { type: blobs[0].type });
  } catch (e) {
    return new Blob(blobs);
  }
};
