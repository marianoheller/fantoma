const waveSurfer = require("wavesurfer.js")


exports.create = function (config) {
  return function () {
    return waveSurfer.create(Object.assign(config, { backend: "MediaElement" }))
  }
}

exports.play = function (ws) {
  return function () {
    ws.play()
  }
}

exports.pause = function (ws) {
  return function () {
    ws.pause()
  }
}

exports.destroy = function (ws) {
  return function () {
    ws.destroy()
  }
}

exports.load = function (url) {
  return function (ws) {
    return function () {
      ws.load(url)
    }
  }
}