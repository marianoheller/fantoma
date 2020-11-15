const waveSurfer = require("wavesurfer.js")


exports.create = function (config) {
  return function () {
    /* TODO: move defaults to PS */
    return waveSurfer.create(Object.assign(config, { pixelRatio: 1, responsive: true }))
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

exports.playPause = function (ws) {
  return function () {
    ws.playPause()
  }
}

exports.stop = function (ws) {
  return function () {
    ws.stop()
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

exports.on = function (event) {
  return function (cb) {
    return function (ws) {
      return function () {
        ws.on(event, (...args) => cb(...args)())
      }
    }
  }
}