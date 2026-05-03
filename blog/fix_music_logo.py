from pathlib import Path
import re
import shutil
from datetime import datetime

root = Path.cwd()

required = [
    root / "hugo.toml",
    root / "layouts/index.html",
    root / "layouts/partials/docs/brand.html",
    root / "layouts/partials/docs/inject/body.html",
]

missing = [str(p) for p in required if not p.exists()]
if missing:
    raise SystemExit("缺少文件：\n" + "\n".join(missing))

backup_dir = root / f"_backup_music_logo_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
backup_dir.mkdir()

for path in required:
    rel = path.relative_to(root)
    dst = backup_dir / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, dst)

# 1. hugo.toml：启用相对 URL，避免 /icon.png 指到仓库根目录
hugo = root / "hugo.toml"
text = hugo.read_text(encoding="utf-8")
text = re.sub(r'(?m)^\s*relativeURLs\s*=.*\n?', '', text)
text = re.sub(r'(?m)^\s*canonifyURLs\s*=.*\n?', '', text)

marker = 'disableKinds = ["taxonomy", "term"]'
if marker in text:
    text = text.replace(marker, marker + '\n\nrelativeURLs = true\ncanonifyURLs = false', 1)
else:
    text = text.rstrip() + '\n\nrelativeURLs = true\ncanonifyURLs = false\n'

hugo.write_text(text, encoding="utf-8")

# 2. brand.html：logo 使用 static/icon.png 生成出的相对地址
(root / "layouts/partials/docs/brand.html").write_text("""{{- $iconURL := "icon.png" | relURL -}}

<h2 class="book-brand jobs-book-brand-wrap">
  <a class="jobs-book-brand"
     href="https://github.com/JobsKits"
     target="_blank"
     rel="noopener noreferrer"
     aria-label="Open JobsKits GitHub">
    <img class="jobs-brand-icon" src="{{ $iconURL }}?v={{ now.Unix }}" alt="Jobs Docs" loading="eager" decoding="sync">
    <span class="jobs-brand-title">Jobs Docs</span>
  </a>
</h2>
""", encoding="utf-8")

# 3. body.html：子页面不再创建 audio，只负责把 iframe 内点击转发给父页面音乐
(root / "layouts/partials/docs/inject/body.html").write_text("""{{- $routesURL := "jobs-container-routes.js" | relURL -}}
<script src="{{ $routesURL }}?v={{ now.Unix }}"></script>

<script>
(function () {
  function normalizePath(path) {
    try {
      return decodeURI(path);
    } catch (error) {
      return path;
    }
  }

  function isContainerRoute(pathname) {
    var currentPath = normalizePath(pathname);
    var routes = window.JOBS_CONTAINER_ROUTES || [];

    return routes.some(function (route) {
      var routePath = normalizePath(new URL(route, window.location.origin).pathname);
      return currentPath === routePath;
    });
  }

  function disableContainerLinks() {
    var routes = window.JOBS_CONTAINER_ROUTES || [];

    routes.forEach(function (route) {
      var routePath = normalizePath(new URL(route, window.location.origin).pathname);

      document.querySelectorAll("a[href]").forEach(function (link) {
        var linkPath = normalizePath(new URL(link.href, window.location.origin).pathname);

        if (linkPath === routePath) {
          link.classList.add("jobs-container-link");
          link.setAttribute("aria-disabled", "true");
          link.setAttribute("tabindex", "-1");
        }
      });
    });
  }

  function setupContainerClickGuard() {
    document.addEventListener("click", function (event) {
      var link = event.target.closest && event.target.closest("a[href]");

      if (!link) {
        return;
      }

      var pathname = new URL(link.href, window.location.origin).pathname;

      if (isContainerRoute(pathname)) {
        event.preventDefault();
        event.stopPropagation();
        link.blur();
      }
    }, true);
  }

  function fixIconCache() {
    var nextSrc = {{ printf "%s?v=%d" ("icon.png" | relURL) now.Unix | jsonify }};

    document.querySelectorAll('img[src*="/icon.png"], img[src*="icon.png"]').forEach(function (img) {
      img.setAttribute("src", nextSrc);
      img.setAttribute("loading", "eager");
      img.setAttribute("decoding", "sync");
    });
  }

  function getMusicTargetOrigin() {
    return window.location.origin && window.location.origin !== "null" ? window.location.origin : "*";
  }

  function unlockShellMusic() {
    try {
      if (
        window.parent &&
        window.parent !== window &&
        window.parent.JobsDocsMusic &&
        typeof window.parent.JobsDocsMusic.unlock === "function"
      ) {
        window.parent.JobsDocsMusic.unlock();
        return;
      }
    } catch (error) {}

    try {
      if (window.parent && window.parent !== window) {
        window.parent.postMessage({ type: "jobsdocs:unlock-music" }, getMusicTargetOrigin());
      }
    } catch (error) {}
  }

  function setupShellMusicUnlockForwarding() {
    document.addEventListener("pointerdown", unlockShellMusic, { once: true, capture: true });
    document.addEventListener("touchstart", unlockShellMusic, { once: true, capture: true });
    document.addEventListener("keydown", unlockShellMusic, { once: true, capture: true });
    document.addEventListener("click", unlockShellMusic, { once: true, capture: true });
  }

  document.addEventListener("DOMContentLoaded", function () {
    fixIconCache();
    disableContainerLinks();
    setupContainerClickGuard();
    setupShellMusicUnlockForwarding();
  });
})();
</script>

<style>
.jobs-container-link {
  cursor: default !important;
  pointer-events: auto !important;
}

.jobs-container-link:hover {
  color: inherit !important;
  text-decoration: none !important;
}
</style>
""", encoding="utf-8")

# 4. index.html：首页父页面持有唯一 audio；iframe 点击会解锁这个 audio
(root / "layouts/index.html").write_text("""{{- $docs := where .Site.RegularPages "Section" "docs" -}}
{{- $sortedDocs := sort $docs "Weight" "asc" -}}
{{- $firstDoc := index $sortedDocs 0 -}}
{{- $musicURL := "With an Orchid.mp3" | relURL -}}

<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <title>{{ .Site.Title }}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <style>
    html,
    body {
      width: 100%;
      height: 100%;
      margin: 0;
      padding: 0;
      overflow: hidden;
      background: #f4f7fb;
    }

    .jobs-docs-shell {
      position: fixed;
      inset: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: #f4f7fb;
    }

    .jobs-docs-frame {
      width: 100%;
      height: 100%;
      border: 0;
      display: block;
      background: #f4f7fb;
    }

    .jobs-audio-player {
      position: fixed;
      left: 24px;
      bottom: 24px;
      z-index: 9999;
      width: 320px;
      padding: 12px 14px;
      border-radius: 18px;
      background: rgba(255, 255, 255, 0.94);
      border: 1px solid rgba(219, 228, 238, 0.95);
      box-shadow: 0 12px 34px rgba(15, 23, 42, 0.16);
      backdrop-filter: blur(10px);
    }

    .jobs-audio-title {
      margin-bottom: 8px;
      color: #1f2937;
      font-size: 0.92rem;
      font-weight: 750;
    }

    .jobs-audio-player audio {
      width: 100%;
      height: 36px;
    }

    @media screen and (max-width: 56rem) {
      .jobs-audio-player {
        left: 12px;
        right: 12px;
        bottom: 12px;
        width: auto;
      }
    }
  </style>
</head>

<body>
  <div class="jobs-docs-shell">
    {{- if $firstDoc }}
    <iframe
      id="jobs-docs-frame"
      class="jobs-docs-frame"
      name="jobs-docs-frame"
      src="{{ $firstDoc.RelPermalink | relURL }}"
      title="Jobs Docs"
      allow="autoplay">
    </iframe>
    {{- else }}
    <div style="padding: 24px;">暂无文档。</div>
    {{- end }}
  </div>

  <div class="jobs-audio-player">
    <div class="jobs-audio-title">🎵 With an Orchid</div>
    <audio id="jobs-bg-music" controls autoplay loop preload="auto" playsinline>
      <source src="{{ $musicURL }}" type="audio/mpeg">
      当前浏览器不支持 audio 标签。
    </audio>
  </div>

  <script>
    (function () {
      var audio = document.getElementById("jobs-bg-music");
      var frame = document.getElementById("jobs-docs-frame");

      if (!audio) {
        return;
      }

      var storagePrefix = "jobsdocs.shellMusic.";
      var timeKey = storagePrefix + "currentTime";
      var volumeKey = storagePrefix + "volume";
      var defaultVolume = 0.42;
      var hasTriedMutedAutoplay = false;

      function getNumberFromStorage(key, fallback) {
        var value = window.localStorage.getItem(key);
        var numberValue = Number(value);

        if (!Number.isFinite(numberValue)) {
          return fallback;
        }

        return numberValue;
      }

      function restoreVolume() {
        var volume = getNumberFromStorage(volumeKey, defaultVolume);

        if (volume <= 0 || volume > 1) {
          volume = defaultVolume;
        }

        audio.volume = volume;
        audio.muted = false;
        audio.defaultMuted = false;
      }

      function restoreCurrentTime() {
        var savedTime = getNumberFromStorage(timeKey, 0);

        if (savedTime <= 0) {
          return;
        }

        try {
          if (Number.isFinite(audio.duration) && audio.duration > 0) {
            audio.currentTime = savedTime % audio.duration;
          } else {
            audio.currentTime = savedTime;
          }
        } catch (error) {}
      }

      function saveState() {
        if (Number.isFinite(audio.currentTime)) {
          window.localStorage.setItem(timeKey, String(audio.currentTime));
        }

        if (Number.isFinite(audio.volume) && !audio.muted) {
          window.localStorage.setItem(volumeKey, String(audio.volume));
        }
      }

      function tryPlay() {
        var playPromise = audio.play();

        if (playPromise && typeof playPromise.catch === "function") {
          playPromise.catch(function () {
            tryMutedAutoplay();
          });
        }
      }

      function tryMutedAutoplay() {
        if (hasTriedMutedAutoplay) {
          return;
        }

        hasTriedMutedAutoplay = true;

        try {
          audio.muted = true;
          audio.defaultMuted = true;
          var playPromise = audio.play();

          if (playPromise && typeof playPromise.catch === "function") {
            playPromise.catch(function () {});
          }
        } catch (error) {}
      }

      function unlock() {
        audio.muted = false;
        audio.defaultMuted = false;
        tryPlay();
      }

      function isTrustedFrameMessage(event) {
        if (event.origin && event.origin !== "null" && event.origin !== window.location.origin) {
          return false;
        }

        if (frame && event.source && event.source !== frame.contentWindow) {
          return false;
        }

        return true;
      }

      restoreVolume();

      window.JobsDocsMusic = {
        unlock: unlock,
        play: unlock,
        saveState: saveState
      };

      audio.addEventListener("loadedmetadata", function () {
        restoreCurrentTime();
        tryPlay();
      });

      audio.addEventListener("canplay", function () {
        tryPlay();
      }, { once: true });

      audio.addEventListener("timeupdate", saveState);
      audio.addEventListener("volumechange", saveState);

      document.addEventListener("pointerdown", unlock, { once: true, capture: true });
      document.addEventListener("touchstart", unlock, { once: true, capture: true });
      document.addEventListener("keydown", unlock, { once: true, capture: true });
      document.addEventListener("click", unlock, { once: true, capture: true });

      window.addEventListener("message", function (event) {
        if (!isTrustedFrameMessage(event)) {
          return;
        }

        if (event.data && event.data.type === "jobsdocs:unlock-music") {
          unlock();
        }
      });

      window.addEventListener("pagehide", saveState);
      window.addEventListener("beforeunload", saveState);

      tryPlay();
    })();
  </script>
</body>
</html>
""", encoding="utf-8")

print("已修改完成。备份目录：", backup_dir)
print("下一步执行：hugo")
