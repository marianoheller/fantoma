const Wavesurfer = require("wavesurfer.js");
const RegionsPlugin = require("wavesurfer.js/dist/plugin/wavesurfer.regions");

exports.create = function (config) {
  return function () {
    const defaults = {
      pixelRatio: 1,
      responsive: true,
      barWidth: 2,
      barHeight: 1,
      barGap: 1,
      plugins: [
        RegionsPlugin.create({
          regions: [],
          dragSelection: {
            slop: 2,
          },
        }),
      ],
    };

    const ws = Wavesurfer.create(Object.assign(config, defaults));

    ws.on("ready", function () {
      ws.clearRegions();
    });

    ws.on("region-created", function (newId) {
      Object.keys(ws.regions.list)
        .filter((r) => r.id !== newId)
        .forEach((r) => {
          ws.regions.list[r].remove();
        });
    });

    return ws;
  };
};

exports.playRegion = function (ws) {
  return function () {
    const regions = Object.keys(ws.regions.list);
    if (regions.length) ws.regions.list[regions[0]].play();
    else ws.play();
  };
};

exports.play = function (ws) {
  return function () {
    ws.play();
  };
};

exports.pause = function (ws) {
  return function () {
    ws.pause();
  };
};

exports.playPause = function (ws) {
  return function () {
    ws.playPause();
  };
};

exports.stop = function (ws) {
  return function () {
    ws.stop();
  };
};

exports.destroy = function (ws) {
  return function () {
    ws.destroy();
  };
};

exports.load = function (url) {
  return function (ws) {
    return function () {
      ws.load(url);
    };
  };
};

exports.on = function (event) {
  return function (cb) {
    return function (ws) {
      return function () {
        ws.on(event, (...args) => cb(...args)());
      };
    };
  };
};
