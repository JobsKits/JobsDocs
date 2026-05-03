// server.js（适配 v2.x）
const NodeMediaServer = require('node-media-server');
const path = require('path');

const mediaRoot = path.resolve(__dirname, 'media');
console.log('mediaRoot =', mediaRoot);

const config = {
  logType: 3, // 打满日志，方便看 HLS/ffmpeg 有没有跑起来

  rtmp: {
    port: 1935,
    chunk_size: 60000,
    gop_cache: true,
    ping: 30,
    ping_timeout: 60,
  },

  http: {
    port: 8000,
    mediaroot: mediaRoot,
    allow_origin: '*',
  },

  // ✅ v2.x 官方写法：这里才是真正启动 HLS 转封装
  trans: {
    ffmpeg: '/opt/homebrew/bin/ffmpeg', // 你机器上的 ffmpeg 路径
    tasks: [
      {
        app: 'live', // rtmp://IP:1935/live/xxx 里的 live
        hls: true,
        hlsFlags: '[hls_time=2:hls_list_size=3:hls_flags=delete_segments]',
        // dash: true,
        // dashFlags: '[f=dash:window_size=3:extra_window_size=5]',
      },
    ],
  },
};

const nms = new NodeMediaServer(config);

nms.on('postPublish', (id, StreamPath, args) => {
  console.log('[postPublish]', { id: id.id, StreamPath, args });
});

nms.on('donePublish', (id, StreamPath, args) => {
  console.log('[donePublish]', { id: id.id, StreamPath, args });
});

nms.run();

console.log('✅ Node-Media-Server 启动完成');
