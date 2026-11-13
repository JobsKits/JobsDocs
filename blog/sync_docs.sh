#!/usr/bin/env bash

# >>> Jobs terminal style protection v1 >>>
# 临时保护当前终端配色，业务进程自行管理原有退出清理。
jobs_terminal_style_run() {
    # 无法可靠保存原色时，沿用脚本已有的纯文本约定。
    jobs_terminal_style_plain() {
        PLAIN_OUTPUT=1
        NO_COLOR=1
        FORCE_COLOR=0
        CLICOLOR=0
        ANSI_COLORS_DISABLED=1
        npm_config_color=false
        export PLAIN_OUTPUT NO_COLOR FORCE_COLOR CLICOLOR ANSI_COLORS_DISABLED npm_config_color
        if "$@"; then
            jobs_style_exit_status=0
        else
            jobs_style_exit_status=$?
        fi
        exit "$jobs_style_exit_status"
    }
    if [ ! -t 0 ] || [ ! -t 1 ] || [ -z "${TERM:-}" ] ||
       [ "${TERM:-}" = dumb ] || [ "${NO_COLOR+x}" = x ] ||
       [ "${PLAIN_OUTPUT:-0}" = 1 ] || [ "${IS_SOURCETREE_RUNTIME:-0}" = 1 ] ||
       env | LC_ALL=C grep -qiE '^(SOURCETREE|SOURCE_TREE)'; then
        if "$@"; then
            jobs_style_exit_status=0
        else
            jobs_style_exit_status=$?
        fi
        exit "$jobs_style_exit_status"
    fi
    if [ -n "${TMUX:-}${STY:-}" ]; then
        jobs_terminal_style_plain "$@"
    fi
    jobs_style_tty=$(tty 2>/dev/null) || jobs_terminal_style_plain "$@"
    if ! ps -o pgid= -o tpgid= -p "$$" 2>/dev/null |
         LC_ALL=C awk 'NF == 2 && $1 == $2 && $1 > 0 { foreground = 1 } END { exit !foreground }'; then
        jobs_terminal_style_plain "$@"
    fi
    case ${JOBS_TERMINAL_STYLE_OWNER:-} in
        ''|*[!0-9]*) ;;
        *)
            if [ "${JOBS_TERMINAL_STYLE_TTY:-}" = "$jobs_style_tty" ] &&
               kill -0 "$JOBS_TERMINAL_STYLE_OWNER" 2>/dev/null; then
                if "$@"; then
                    jobs_style_exit_status=0
                else
                    jobs_style_exit_status=$?
                fi
                exit "$jobs_style_exit_status"
            fi
            ;;
    esac
    jobs_style_stty=$(stty -g 2>/dev/null < /dev/tty) || jobs_terminal_style_plain "$@"
    jobs_style_saved=''
    jobs_style_saved_rows=''
    jobs_style_applied_rows=''
    jobs_style_changed=0
    jobs_style_applied_complete=0
    jobs_style_query_active=0
    jobs_style_recovery=''
    jobs_style_exit_status=0
    jobs_style_esc=$(printf '\033')
    jobs_style_bel=$(printf '\007')
    # 只接受本次请求对应的 RGB 响应；非协议输入使本次探测失败。
    jobs_terminal_style_query() {
        jobs_style_query_key=$1
        printf '\033]%s;?\007' "$jobs_style_query_key" > /dev/tty || return 1
        jobs_style_reply=''
        for jobs_style_attempt in 1 2 3; do
            jobs_style_piece=$(dd bs=256 count=1 2>/dev/null < /dev/tty)
            jobs_style_reply=$jobs_style_reply$jobs_style_piece
            case $jobs_style_reply in
                *"$jobs_style_bel"|*"$jobs_style_esc\\") break ;;
                '') ;;
                "$jobs_style_esc"*) ;;
                *) break ;;
            esac
        done
        case $jobs_style_reply in
            "$jobs_style_esc]$jobs_style_query_key;rgb:"*"$jobs_style_bel")
                jobs_style_rgb=${jobs_style_reply#"$jobs_style_esc]$jobs_style_query_key;rgb:"}
                jobs_style_rgb=${jobs_style_rgb%"$jobs_style_bel"}
                ;;
            "$jobs_style_esc]$jobs_style_query_key;rgb:"*"$jobs_style_esc\\")
                jobs_style_rgb=${jobs_style_reply#"$jobs_style_esc]$jobs_style_query_key;rgb:"}
                jobs_style_rgb=${jobs_style_rgb%"$jobs_style_esc\\"}
                ;;
            *) return 1 ;;
        esac
        jobs_style_normalized=$(printf '%s\n' "$jobs_style_rgb" | LC_ALL=C awk -F/ '
            NF != 3 { exit 1 }
            {
                for (i = 1; i <= 3; i++) {
                    h = tolower($i)
                    if (length(h) < 1 || length(h) > 4 || h ~ /[^0-9a-f]/) exit 1
                    n = 0
                    for (j = 1; j <= length(h); j++) n = n * 16 + index("0123456789abcdef", substr(h, j, 1)) - 1
                    value[i] = int(n * 65535 / (16 ^ length(h) - 1) + 0.5)
                }
                printf "%d/%d/%d", value[1], value[2], value[3]
            }
        ') || return 1
        [ -n "$jobs_style_normalized" ]
    }
    # 查询可用不代表终端允许改色，按目标值核对实际生效结果。
    jobs_terminal_style_accepts_target() {
        jobs_style_requested_hex=''
        case $1 in
            10|12) jobs_style_requested_hex=ffffff ;;
            11) jobs_style_requested_hex=000000 ;;
            '4;'*)
                jobs_style_requested_index=0
                for jobs_style_requested_color in 000000 ff5f56 5fd787 ffd75f 5fafff d787ff 5fd7ff eeeeee 9e9e9e ff8787 87ffaf ffff87 87bfff ffafff afffff ffffff; do
                    if [ "4;$jobs_style_requested_index" = "$1" ]; then
                        jobs_style_requested_hex=$jobs_style_requested_color
                        break
                    fi
                    jobs_style_requested_index=$((jobs_style_requested_index + 1))
                done
                ;;
        esac
        [ -n "$jobs_style_requested_hex" ] || return 1
        printf '%s|%s\n' "$jobs_style_normalized" "$jobs_style_requested_hex" | LC_ALL=C awk -F'|' '
            function hexbyte(h) {
                return (index("0123456789abcdef", substr(h, 1, 1)) - 1) * 16 + index("0123456789abcdef", substr(h, 2, 1)) - 1
            }
            {
                if (split($1, actual, "/") != 3 || length($2) != 6) exit 1
                for (i = 1; i <= 3; i++) {
                    difference = actual[i] - hexbyte(substr($2, i * 2 - 1, 2)) * 257
                    if (difference < -255 || difference > 255) exit 1
                }
            }
        '
    }
    # 检测到后续改色时只恢复仍由本次保护持有的项，保留独立恢复入口。
    jobs_terminal_style_cleanup() {
        jobs_style_result=$1
        trap '' HUP INT TERM
        if [ "$jobs_style_query_active" = 1 ]; then
            stty "$jobs_style_stty" 2>/dev/null < /dev/tty || :
            jobs_style_query_active=0
        fi
        if [ "$jobs_style_changed" = 1 ]; then
            jobs_style_cleanup_ok=0
            jobs_style_conflicts=''
            jobs_style_restore_safe=''
            if [ "$jobs_style_applied_complete" = 1 ]; then
                jobs_style_stty=$(stty -g 2>/dev/null < /dev/tty) || jobs_style_stty=''
                if [ -n "$jobs_style_stty" ] && stty -echo -icanon min 0 time 1 2>/dev/null < /dev/tty; then
                    jobs_style_query_active=1
                    jobs_style_cleanup_ok=1
                    while IFS='|' read -r jobs_style_key jobs_style_expected jobs_style_original; do
                        [ -n "$jobs_style_key" ] || continue
                        if ! jobs_terminal_style_query "$jobs_style_key"; then
                            jobs_style_cleanup_ok=0
                            break
                        fi
                        if [ "$jobs_style_normalized" = "$jobs_style_expected" ]; then
                            jobs_style_restore_safe=$jobs_style_restore_safe$jobs_style_original
                        else
                            jobs_style_conflicts="$jobs_style_conflicts $jobs_style_key"
                        fi
                    done <<JOBS_STYLE_APPLIED
$jobs_style_applied_rows
JOBS_STYLE_APPLIED
                    stty "$jobs_style_stty" 2>/dev/null < /dev/tty || jobs_style_cleanup_ok=0
                    jobs_style_query_active=0
                fi
            fi
            if [ "$jobs_style_cleanup_ok" = 1 ] && printf '%s\033[0m' "$jobs_style_restore_safe" > /dev/tty; then
                if [ -z "$jobs_style_conflicts" ]; then
                    rm -f "$jobs_style_recovery"
                    rmdir "${jobs_style_recovery%/*}" 2>/dev/null || :
                else
                    printf '检测到运行期间的配色变更，已保留这些项：%s\n' "$jobs_style_conflicts" >&2
                    printf '确认要覆盖后续改色时才使用恢复入口：sh "%s"\n' "$jobs_style_recovery" >&2
                    [ "$jobs_style_result" -ne 0 ] || jobs_style_result=1
                fi
            else
                printf '终端配色未能安全自动恢复；确认覆盖当前配色后可运行：sh "%s"\n' "$jobs_style_recovery" >&2
                [ "$jobs_style_result" -ne 0 ] || jobs_style_result=1
            fi
        fi
        if [ "${2:-}" = continue ]; then
            jobs_style_cleanup_status=$jobs_style_result
            return 0
        fi
        exit "$jobs_style_result"
    }
    trap 'jobs_terminal_style_cleanup "$jobs_style_exit_status"' 0
    trap 'jobs_style_exit_status=129; exit 129' HUP
    trap 'jobs_style_exit_status=130; exit 130' INT
    trap 'jobs_style_exit_status=143; exit 143' TERM
    if ! stty -echo -icanon min 0 time 1 2>/dev/null < /dev/tty; then
        jobs_terminal_style_plain "$@"
    fi
    jobs_style_query_active=1
    jobs_style_probe_ok=1
    for jobs_style_key in 10 11 12 '4;0' '4;1' '4;2' '4;3' '4;4' '4;5' '4;6' '4;7' '4;8' '4;9' '4;10' '4;11' '4;12' '4;13' '4;14' '4;15'; do
        if ! jobs_terminal_style_query "$jobs_style_key"; then
            jobs_style_probe_ok=0
            break
        fi
        jobs_style_saved=$jobs_style_saved$jobs_style_reply
        jobs_style_saved_rows="$jobs_style_saved_rows$jobs_style_key|$jobs_style_reply
"
    done
    stty "$jobs_style_stty" 2>/dev/null < /dev/tty || { jobs_style_exit_status=1; exit 1; }
    jobs_style_query_active=0
    if [ "$jobs_style_probe_ok" != 1 ]; then
        printf '%s\n' '终端不支持完整配色保存，或启动时收到其它输入；保留原配色并使用纯文本。' >&2
        jobs_terminal_style_plain "$@"
    fi
    jobs_style_recovery_dir=$(umask 077; mktemp -d "${TMPDIR:-/tmp}/jobs-terminal-style.XXXXXX") || jobs_terminal_style_plain "$@"
    jobs_style_recovery=$jobs_style_recovery_dir/restore.sh
    if ! (umask 077; {
        printf '#!/bin/sh\n'
        printf '[ -t 0 ] && [ "$(tty)" = '\''%s'\'' ] || { printf '\''请在原终端运行恢复入口。\\n'\'' >&2; exit 1; }\n' "$jobs_style_tty"
        printf 'printf '\''本操作会覆盖此终端当前配色。确认恢复脚本启动前的配色，请输入 YES：'\'' >&2\n'
        printf 'IFS= read -r jobs_restore_choice\n[ "$jobs_restore_choice" = YES ] || exit 1\n'
        printf 'printf '\''%%s\\033[0m'\'' '\''%s'\'' > /dev/tty\n' "$jobs_style_saved"
    } > "$jobs_style_recovery"); then
        printf '%s\n' '无法保存终端配色恢复入口；保留原配色并使用纯文本。' >&2
        jobs_terminal_style_plain "$@"
    fi
    printf '正在准备本次终端临时配色；强退后恢复入口：sh "%s"\n' "$jobs_style_recovery" >&2
    jobs_style_changed=1
    printf '\033]10;#ffffff\007\033]11;#000000\007\033]12;#ffffff\007' > /dev/tty
    jobs_style_index=0
    for jobs_style_color in 000000 ff5f56 5fd787 ffd75f 5fafff d787ff 5fd7ff eeeeee 9e9e9e ff8787 87ffaf ffff87 87bfff ffafff afffff ffffff; do
        printf '\033]4;%s;#%s\007' "$jobs_style_index" "$jobs_style_color" > /dev/tty
        jobs_style_index=$((jobs_style_index + 1))
    done
    printf '\033[0m' > /dev/tty
    jobs_style_stty=$(stty -g 2>/dev/null < /dev/tty) || { jobs_style_exit_status=1; exit 1; }
    stty -echo -icanon min 0 time 1 2>/dev/null < /dev/tty || { jobs_style_exit_status=1; exit 1; }
    jobs_style_query_active=1
    jobs_style_probe_ok=1
    jobs_style_targets_ok=1
    while IFS='|' read -r jobs_style_key jobs_style_original; do
        [ -n "$jobs_style_key" ] || continue
        if ! jobs_terminal_style_query "$jobs_style_key"; then
            jobs_style_probe_ok=0
            break
        fi
        jobs_style_applied_rows="$jobs_style_applied_rows$jobs_style_key|$jobs_style_normalized|$jobs_style_original
"
        if ! jobs_terminal_style_accepts_target "$jobs_style_key"; then
            jobs_style_targets_ok=0
        fi
    done <<JOBS_STYLE_ORIGINAL
$jobs_style_saved_rows
JOBS_STYLE_ORIGINAL
    stty "$jobs_style_stty" 2>/dev/null < /dev/tty || { jobs_style_exit_status=1; exit 1; }
    jobs_style_query_active=0
    if [ "$jobs_style_probe_ok" != 1 ]; then
        printf '%s\n' '无法核实本次临时配色，已停止启动业务。' >&2
        jobs_style_exit_status=1
        exit 1
    fi
    jobs_style_applied_complete=1
    if [ "$jobs_style_targets_ok" != 1 ]; then
        jobs_terminal_style_cleanup 0 continue
        jobs_style_changed=0
        if [ "$jobs_style_cleanup_status" != 0 ]; then
            jobs_style_exit_status=1
            exit 1
        fi
        trap 'jobs_style_exit_status=129; exit 129' HUP
        trap 'jobs_style_exit_status=130; exit 130' INT
        trap 'jobs_style_exit_status=143; exit 143' TERM
        printf '%s\n' '终端未接受本次配色，已恢复原配色并使用纯文本。' >&2
        jobs_terminal_style_plain "$@"
    fi
    printf '%s\n' '本次终端已临时使用黑底白字。' >&2
    JOBS_TERMINAL_STYLE_TTY=$jobs_style_tty
    JOBS_TERMINAL_STYLE_OWNER=$$
    export JOBS_TERMINAL_STYLE_TTY JOBS_TERMINAL_STYLE_OWNER
    if "$@"; then
        jobs_style_exit_status=0
    else
        jobs_style_exit_status=$?
    fi
    exit "$jobs_style_exit_status"
}
# 仅监督直接执行的入口；被 source 时不切换配色、不重新执行业务。
jobs_terminal_style_bootstrap() {
    jobs_style_bootstrap_script=$1
    shift
    if [ -n "${ZSH_VERSION:-}" ]; then
        case ${ZSH_EVAL_CONTEXT:-} in
            *:file|*:file:*) return 0 ;;
        esac
    elif [ -n "${BASH_VERSION:-}" ] && [ "${BASH_SOURCE:-$jobs_style_bootstrap_script}" != "$jobs_style_bootstrap_script" ]; then
        return 0
    fi
    if [ "${JOBS_TERMINAL_STYLE_REEXEC:-}" = "$jobs_style_bootstrap_script" ]; then
        unset JOBS_TERMINAL_STYLE_REEXEC
        return 0
    fi
    if [ ! -t 0 ] || [ ! -t 1 ] || [ -z "${TERM:-}" ] ||
       [ "${TERM:-}" = dumb ] || [ "${NO_COLOR+x}" = x ] ||
       [ "${PLAIN_OUTPUT:-0}" = 1 ] || [ "${IS_SOURCETREE_RUNTIME:-0}" = 1 ] ||
       [ -n "${TMUX:-}${STY:-}" ] ||
       env | LC_ALL=C grep -qiE '^(SOURCETREE|SOURCE_TREE)'; then
        return 0
    fi
    case ${JOBS_TERMINAL_STYLE_OWNER:-} in
        ''|*[!0-9]*) ;;
        *)
            if kill -0 "$JOBS_TERMINAL_STYLE_OWNER" 2>/dev/null &&
               [ "${JOBS_TERMINAL_STYLE_TTY:-}" = "$(tty 2>/dev/null)" ]; then
                return 0
            fi
            ;;
    esac
    JOBS_TERMINAL_STYLE_REEXEC=$jobs_style_bootstrap_script
    export JOBS_TERMINAL_STYLE_REEXEC
    jobs_terminal_style_run /usr/bin/env bash "$jobs_style_bootstrap_script" "$@"
    jobs_style_bootstrap_result=$?
    exit "$jobs_style_bootstrap_result"
}
jobs_terminal_style_bootstrap "$0" "$@"
# <<< Jobs terminal style protection v1 <<<

# jobsdocs-git-version-start
STATIC_DIR="$BLOG_DIR/static"
mkdir -p "$STATIC_DIR"

JOBS_DOCS_GIT_COMMIT=""
if command -v git >/dev/null 2>&1; then
  JOBS_DOCS_GIT_COMMIT="$(git -C "$ROOT_DIR" rev-parse --short=7 HEAD 2>/dev/null || true)"
fi

if [ -z "$JOBS_DOCS_GIT_COMMIT" ] && [ -n "${CF_PAGES_COMMIT_SHA:-}" ]; then
  JOBS_DOCS_GIT_COMMIT="$(printf "%.7s" "$CF_PAGES_COMMIT_SHA")"
fi

if [ -z "$JOBS_DOCS_GIT_COMMIT" ] && [ -n "${GITHUB_SHA:-}" ]; then
  JOBS_DOCS_GIT_COMMIT="$(printf "%.7s" "$GITHUB_SHA")"
fi

if [ -z "$JOBS_DOCS_GIT_COMMIT" ]; then
  JOBS_DOCS_GIT_COMMIT="unknown"
fi

cat > "$STATIC_DIR/jobs-git-version.js" <<EOF
window.JOBS_DOCS_GIT_VERSION = "$JOBS_DOCS_GIT_COMMIT";
EOF

echo "Git Version: $JOBS_DOCS_GIT_COMMIT"
# jobsdocs-git-version-end

set -eo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly BLOG_DIR="$ROOT_DIR/blog"
readonly CONTENT_DIR="$BLOG_DIR/content/docs"
readonly OBSOLETE_POSTS_DIR="$BLOG_DIR/content/posts"
readonly CONTAINER_ROUTES_FILE="$BLOG_DIR/static/jobs-container-routes.js"
readonly HEAD_INJECTION_FILE="$BLOG_DIR/layouts/partials/docs/inject/head.html"
readonly BODY_INJECTION_FILE="$BLOG_DIR/layouts/partials/docs/inject/body.html"

WEIGHT_VALUE=10
PUBLISHABLE_MARKDOWN_FILES=()
PUBLISHABLE_PDF_FILES=()
CHILD_DIRECTORIES=()

# 输出普通日志。
log() {
    printf '%s\n' "$*"
}

# 输出错误日志。
log_error() {
    printf 'Error: %s\n' "$*" >&2
}

# 转换成小写字符串。
to_lower() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

# 转义 JS 字符串。
escape_js_string() {
    local value="$1"

    printf '%s' "$value" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# 初始化容器目录路由文件。
# 没有直属 md 的目录只作为左侧目录容器，不允许点击进入空页面。
prepare_container_routes_file() {
    mkdir -p "$BLOG_DIR/static"
    printf '%s\n' 'window.JOBS_CONTAINER_ROUTES = [];' > "$CONTAINER_ROUTES_FILE"
}

# 记录容器目录路由。
record_container_route() {
    local target_dir="$1"
    local rel_path
    local route
    local safe_route

    rel_path="${target_dir#$CONTENT_DIR/}"

    if [[ "$rel_path" == "$target_dir" || -z "$rel_path" ]]; then
        return
    fi

    route="/docs/$rel_path/"
    safe_route="$(escape_js_string "$route")"

    printf 'window.JOBS_CONTAINER_ROUTES.push("%s");\n' "$safe_route" >> "$CONTAINER_ROUTES_FILE"
}

# 写入 Hugo Book body 注入文件。
# 这里负责：
# 1. 禁止容器目录点击进入空页面；
# 2. 强制 logo 使用 Hugo static 下的 icon.png 并追加缓存版本。
# 背景音乐只挂在首页外层 shell，避免 iframe 子页面切换时重新播放。
ensure_body_injection() {
    mkdir -p "$(dirname "$BODY_INJECTION_FILE")"

    cat > "$BODY_INJECTION_FILE" <<'EOF'
<script src="{{ "jobs-container-routes.js" | relURL }}?v={{ now.Unix }}"></script>

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

  function removeUnsupportedRtfdMenuItems() {
    document.querySelectorAll(".book-menu nav a[href]").forEach(function (link) {
      var pathname = normalizePath(new URL(link.href, window.location.origin).pathname).toLowerCase();

      if (pathname.indexOf("签名价格调研.rtfd") !== -1 || pathname.indexOf("%e7%ad%be%e5%90%8d%e4%bb%b7%e6%a0%bc%e8%b0%83%e7%a0%94.rtfd") !== -1) {
        var item = link.closest("li");

        if (item) {
          item.remove();
        }
      }
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

  function fixBrandIcon() {
    var nextSrc = "{{ "icon.png" | relURL }}?v={{ now.Unix }}";

    document.querySelectorAll(".jobs-brand-icon").forEach(function (img) {
      img.setAttribute("src", nextSrc);
      img.setAttribute("loading", "eager");
      img.setAttribute("decoding", "sync");
    });
  }

  function notifyShellMusic() {
    try {
      if (!window.parent || window.parent === window) {
        return;
      }

      var parentMusic = window.parent.JobsDocsMusic;

      if (parentMusic && typeof parentMusic.unlockFromFrame === "function") {
        parentMusic.unlockFromFrame();
        return;
      }

      window.parent.postMessage({ type: "jobsdocs:unlock-music" }, window.location.origin);
    } catch (error) {
      try {
        window.parent.postMessage({ type: "jobsdocs:unlock-music" }, window.location.origin);
      } catch (nestedError) {
        // 忽略跨域或浏览器限制。
      }
    }
  }

  document.addEventListener("DOMContentLoaded", function () {
    fixBrandIcon();
    removeUnsupportedRtfdMenuItems();
    disableContainerLinks();
    setupContainerClickGuard();
  });

  ["pointerdown", "click", "touchstart", "keydown"].forEach(function (eventName) {
    document.addEventListener(eventName, notifyShellMusic, { capture: true });
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

EOF
}

# 写入首屏主题初始化，并把可见切换按钮追加到 Hugo Book 正文页。
ensure_theme_runtime() {
    mkdir -p "$(dirname "$HEAD_INJECTION_FILE")"

    cat > "$HEAD_INJECTION_FILE" <<'EOF'
<script>
(function () {
  var storageKey = "jobsdocs.theme";
  var root = document.documentElement;
  var storedTheme = null;

  try {
    storedTheme = window.localStorage.getItem(storageKey);
  } catch (error) {}

  if (storedTheme !== "light" && storedTheme !== "dark") {
    storedTheme = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  root.setAttribute("data-jobs-theme", storedTheme);
  root.style.colorScheme = storedTheme;
  root.classList.toggle("jobs-theme-embedded", window.parent !== window);
  window.JOBS_DOCS_THEME_BOOTSTRAP = {
    storageKey: storageKey,
    theme: storedTheme
  };
})();
</script>
EOF

    cat >> "$BODY_INJECTION_FILE" <<'EOF'

<!-- jobsdocs-theme-runtime -->
<button id="jobs-theme-toggle" class="jobs-theme-toggle" type="button">
  <span class="jobs-theme-toggle-label">黑夜模式</span>
</button>
<script>
(function () {
  var bootstrap = window.JOBS_DOCS_THEME_BOOTSTRAP || {};
  var storageKey = bootstrap.storageKey || "jobsdocs.theme";
  var root = document.documentElement;
  var mediaQuery = window.matchMedia ? window.matchMedia("(prefers-color-scheme: dark)") : null;
  var button = null;

  function normalizeTheme(theme) {
    return theme === "dark" || theme === "light" ? theme : null;
  }

  function readStoredTheme() {
    try {
      return normalizeTheme(window.localStorage.getItem(storageKey));
    } catch (error) {
      return null;
    }
  }

  function systemTheme() {
    return mediaQuery && mediaQuery.matches ? "dark" : "light";
  }

  function updateThemeColor(theme) {
    var meta = document.querySelector('meta[name="theme-color"][data-jobs-theme-color]');

    if (!meta) {
      meta = document.createElement("meta");
      meta.name = "theme-color";
      meta.setAttribute("data-jobs-theme-color", "true");
      document.head.appendChild(meta);
    }

    meta.content = theme === "dark" ? "#0f172a" : "#f4f7fb";
  }

  function syncButton(theme) {
    if (!button) {
      return;
    }

    var nextThemeName = theme === "dark" ? "白天模式" : "黑夜模式";
    var label = button.querySelector(".jobs-theme-toggle-label");

    if (label) {
      label.textContent = nextThemeName;
    }

    button.setAttribute("aria-label", "切换为" + nextThemeName);
    button.setAttribute("title", "切换为" + nextThemeName);
    button.setAttribute("aria-pressed", theme === "dark" ? "true" : "false");
  }

  function applyTheme(theme, persist) {
    var nextTheme = normalizeTheme(theme) || systemTheme();

    root.setAttribute("data-jobs-theme", nextTheme);
    root.style.colorScheme = nextTheme;

    if (document.body) {
      document.body.classList.toggle("dark", nextTheme === "dark");
      document.body.classList.toggle("light", nextTheme === "light");
    }

    if (persist) {
      try {
        window.localStorage.setItem(storageKey, nextTheme);
      } catch (error) {}
    }

    updateThemeColor(nextTheme);
    syncButton(nextTheme);
    return nextTheme;
  }

  function notifyParent(theme) {
    try {
      if (window.parent && window.parent !== window) {
        window.parent.postMessage({ type: "jobsdocs:theme-changed", theme: theme }, window.location.origin);
      }
    } catch (error) {}
  }

  function toggleTheme() {
    var currentTheme = normalizeTheme(root.getAttribute("data-jobs-theme")) || systemTheme();
    var nextTheme = applyTheme(currentTheme === "dark" ? "light" : "dark", true);

    notifyParent(nextTheme);
  }

  function boot() {
    button = document.getElementById("jobs-theme-toggle");

    if (button) {
      button.hidden = window.parent !== window;

      if (!button.__jobsThemeHooked) {
        button.__jobsThemeHooked = true;
        button.addEventListener("click", toggleTheme);
      }
    }

    applyTheme(readStoredTheme() || bootstrap.theme || systemTheme(), false);
  }

  window.addEventListener("message", function (event) {
    if (event.origin !== window.location.origin || !event.data || event.data.type !== "jobsdocs:set-theme") {
      return;
    }

    applyTheme(event.data.theme, false);
  });

  window.addEventListener("storage", function (event) {
    if (event.key === storageKey) {
      applyTheme(normalizeTheme(event.newValue) || systemTheme(), false);
    }
  });

  if (mediaQuery) {
    var handleSystemThemeChange = function () {
      if (!readStoredTheme()) {
        applyTheme(systemTheme(), false);
      }
    };

    if (typeof mediaQuery.addEventListener === "function") {
      mediaQuery.addEventListener("change", handleSystemThemeChange);
    } else if (typeof mediaQuery.addListener === "function") {
      mediaQuery.addListener(handleSystemThemeChange);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
</script>
<!-- /jobsdocs-theme-runtime -->
EOF
}

# 获取文件大小，兼容 macOS 和 Linux。
get_file_size_bytes() {
    local file="$1"

    if stat -f%z "$file" >/dev/null 2>&1; then
        stat -f%z "$file"
        return
    fi

    if stat -c%s "$file" >/dev/null 2>&1; then
        stat -c%s "$file"
        return
    fi

    wc -c < "$file" | tr -d ' '
}

# 判断文件是否超过 Cloudflare Pages 单文件 25 MiB 限制。
is_cloudflare_pages_oversized_file() {
    local file="$1"
    local size
    local max_size=26214400

    size="$(get_file_size_bytes "$file")"

    [[ "$size" -ge "$max_size" ]]
}

# 转义 YAML 双引号字符串。
escape_yaml_string() {
    local value="$1"

    printf '%s' "$value" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# 判断路径片段是否是 .md 结尾的文件夹名。
is_markdown_named_dir_segment() {
    local segment="$1"
    local lower_segment

    lower_segment="$(to_lower "$segment")"

    [[ "$lower_segment" == *.md ]]
}

# 去掉文件名或目录名末尾的 .md。
strip_markdown_suffix() {
    local value="$1"
    local lower_value

    lower_value="$(to_lower "$value")"

    if [[ "$lower_value" == *.md ]]; then
        value="${value%.*}"
    fi

    printf '%s' "$value"
}

# 清理 Markdown 标题里的 Markdown 语法。
strip_markdown_for_title() {
    local value="$1"

    printf '%s' "$value" \
        | sed -E 's/!\[([^][]*)\]\([^)]+\)//g' \
        | sed -E 's/\[([^][]+)\]\([^)]+\)/\1/g' \
        | sed -E 's/\*\*([^*]+)\*\*/\1/g' \
        | sed -E 's/__([^_]+)__/\1/g' \
        | sed -E 's/`([^`]+)`/\1/g' \
        | sed -E 's/<br[[:space:]]*\/?>/ /g' \
        | sed -E 's/<[^>]+>//g' \
        | sed -E 's/[[:space:]]+/ /g' \
        | sed -E 's/^[[:space:]]+|[[:space:]]+$//g'
}

# 清理摘要里的 Markdown 和 HTML。
strip_markdown_for_summary() {
    local value="$1"

    printf '%s' "$value" \
        | sed -E 's/!\[([^][]*)\]\([^)]+\)//g' \
        | sed -E 's/\[([^][]+)\]\([^)]+\)/\1/g' \
        | sed -E 's/<br[[:space:]]*\/?>/ /g' \
        | sed -E 's/<[^>]+>//g' \
        | sed -E 's/`([^`]+)`/\1/g' \
        | sed -E 's/\*\*([^*]+)\*\*/\1/g' \
        | sed -E 's/__([^_]+)__/\1/g' \
        | sed -E 's/\*([^*]+)\*/\1/g' \
        | sed -E 's/_([^_]+)_/\1/g' \
        | sed -E 's/^[[:space:]]*[>#-]+[[:space:]]*//g' \
        | sed -E 's/[[:space:]]+/ /g' \
        | sed -E 's/^[[:space:]]+|[[:space:]]+$//g'
}

# 把标题转换成可作为目录名的安全片段。
make_safe_path_segment() {
    local value="$1"

    value="$(printf '%s' "$value" \
        | sed 's#/#／#g' \
        | sed 's#:：#：#g' \
        | sed 's#[[:space:]]\+# #g' \
        | sed 's#^[[:space:]]*##; s#[[:space:]]*$##')"

    if [[ -z "$value" ]]; then
        value="Untitled"
    fi

    printf '%s' "$value"
}

# 拼接标题前缀。
join_title_prefix() {
    local prefix="$1"
    local title="$2"

    if [[ -z "$prefix" ]]; then
        printf '%s' "$title"
    else
        printf '%s/%s' "$prefix" "$title"
    fi
}

# 从 Markdown 的第一个标题里提取文章标题。
get_title_from_markdown() {
    local file="$1"
    local fallback="$2"
    local title

    title="$(
        grep -m 1 -E '^#{1,6}[[:space:]]*.+' "$file" \
            | sed -E 's/^#{1,6}[[:space:]]*//' \
            || true
    )"

    if [[ -z "$title" ]]; then
        title="$fallback"
    fi

    title="$(strip_markdown_for_title "$title")"

    printf '%s' "$title"
}

# 获取文件最后一次 Git 提交时间，没有提交时使用当前时间。
get_git_date() {
    local file="$1"
    local date_value

    date_value="$(git -C "$ROOT_DIR" log -1 --format=%cI -- "$file" 2>/dev/null || true)"

    if [[ -z "$date_value" ]]; then
        date_value="$(date '+%Y-%m-%dT%H:%M:%S%z')"
    fi

    printf '%s' "$date_value"
}

# 获取目录标题。
get_dir_title() {
    local dir="$1"
    local dirname_value

    dirname_value="$(basename "$dir")"

    # jobsdocs-v17-skip-rtfd-directory
    # RTFD 是 macOS 富文本包，Hugo/Markdown 站点无法正确展示，统一跳过。
    if [[ "$(to_lower "$dirname_value")" == *.rtfd ]]; then
        return 0
    fi
    dirname_value="$(strip_markdown_suffix "$dirname_value")"

    printf '%s' "$dirname_value"
}

# 获取 Markdown 文件名标题。
get_file_title_fallback() {
    local file="$1"
    local filename
    local basename_no_ext

    filename="$(basename "$file")"
    basename_no_ext="${filename%.md}"
    basename_no_ext="$(strip_markdown_suffix "$basename_no_ext")"

    printf '%s' "$basename_no_ext"
}

# 判断文件是否是 README.md。
is_readme_markdown() {
    local file="$1"
    local filename

    filename="$(basename "$file")"
    filename="$(to_lower "$filename")"

    [[ "$filename" == "readme.md" ]]
}

# 判断文件的父目录是否是 .md 命名的包裹目录。
is_inside_markdown_named_dir() {
    local file="$1"
    local parent_dir
    local parent_name

    parent_dir="$(dirname "$file")"
    parent_name="$(basename "$parent_dir")"

    is_markdown_named_dir_segment "$parent_name"
}

# 修复正文中常见的非标准 Markdown 链接写法。
# 例如：[ReactNative](# https://reactnative.dev/) 会被转换成 [ReactNative](https://reactnative.dev/)。
normalize_markdown_body() {
    sed -E 's|\]\([[:space:]]*#[[:space:]]*(https?://[^)]+)\)|](\1)|g'
}

# 生成摘要。
get_summary() {
    local file="$1"
    local summary_text

    summary_text="$(
        awk '
            BEGIN {
                in_front_matter = 0
                in_code_block = 0
                removed_first_heading = 0
            }

            NR == 1 {
                if ($0 == "---" || $0 == "+++") {
                    in_front_matter = 1
                    front_matter_marker = $0
                    next
                }
            }

            in_front_matter == 1 {
                if ($0 == front_matter_marker) {
                    in_front_matter = 0
                }

                next
            }

            /^[[:space:]]*```/ || /^[[:space:]]*~~~/ {
                in_code_block = !in_code_block
                next
            }

            in_code_block == 1 {
                next
            }

            {
                line = $0
                lower_line = tolower(line)

                if (removed_first_heading == 0 && line ~ /^#{1,6}[[:space:]]*.*/) {
                    removed_first_heading = 1
                    next
                }

                if (lower_line ~ /^[[:space:]]*\[toc\][[:space:]]*$/) {
                    next
                }

                if (line ~ /^[[:space:]]*!\[[^]]*\]\([^)]+\)[[:space:]]*$/) {
                    next
                }

                if (line ~ /^[[:space:]]*$/) {
                    next
                }

                print line
            }
        ' "$file" | tr '\n' ' '
    )"

    summary_text="$(strip_markdown_for_summary "$summary_text")"
    summary_text="${summary_text:0:180}"

    printf '%s' "$summary_text"
}

# 判断路径是否属于需要跳过的通用目录。
should_skip_common_path() {
    local rel_path="$1"
    local lower_path

    lower_path="$(to_lower "$rel_path")"

    if [[ "$lower_path" == blog/* ]]; then
        return 0
    fi

    if [[ "$lower_path" == .git/* || "$lower_path" == .github/* ]]; then
        return 0
    fi

    if [[ "$lower_path" == */node_modules/* ]]; then
        return 0
    fi

    if [[ "$lower_path" == */vendor/* ]]; then
        return 0
    fi

    if [[ "$lower_path" == */pods/* ]]; then
        return 0
    fi

    if [[ "$lower_path" == */build/* ]]; then
        return 0
    fi

    if [[ "$lower_path" == */dist/* ]]; then
        return 0
    fi

    if [[ "$lower_path" == */public/* ]]; then
        return 0
    fi

    if [[ "$lower_path" == */coverage/* ]]; then
        return 0
    fi

    if [[ "$lower_path" == */.cache/* ]]; then
        return 0
    fi

    return 1
}

# 判断目录是否应该跳过。
should_skip_directory() {
    local dir="$1"
    local rel_path
    local lower_path
    local dirname_value

    if [[ "$dir" == "$ROOT_DIR" ]]; then
        return 1
    fi

    rel_path="${dir#$ROOT_DIR/}"
    lower_path="$(to_lower "$rel_path")"
    dirname_value="$(basename "$dir")"

    if should_skip_common_path "$rel_path/"; then
        return 0
    fi

    if [[ "$(to_lower "$dirname_value")" == *.rtfd ]]; then
        return 0
    fi

    if [[ "$dirname_value" == "assets" ]]; then
        return 0
    fi

    if [[ "$lower_path" == */assets ]]; then
        return 0
    fi

    return 1
}

# 判断 Markdown 是否应该跳过。
should_skip_markdown() {
    local file="$1"
    local rel_path
    local filename
    local lower_filename

    rel_path="${file#$ROOT_DIR/}"
    filename="$(basename "$file")"
    lower_filename="$(to_lower "$filename")"

    if should_skip_common_path "$rel_path"; then
        return 0
    fi

    if [[ "$lower_filename" == "readme.md" ]]; then
        if is_inside_markdown_named_dir "$file"; then
            return 1
        fi

        return 0
    fi

    case "$lower_filename" in
        readme-*.md)
            return 0
            ;;
        changelog.md|change-log.md|changes.md|history.md|release.md|releases.md)
            return 0
            ;;
        license.md|licence.md|copying.md|notice.md)
            return 0
            ;;
        contributing.md|contributors.md|code_of_conduct.md|security.md)
            return 0
            ;;
    esac

    if [[ "$lower_filename" == changelog* || "$lower_filename" == *changelog.md ]]; then
        return 0
    fi

    if [[ "$lower_filename" == changes* || "$lower_filename" == *changes.md ]]; then
        return 0
    fi

    if [[ "$lower_filename" == history* || "$lower_filename" == *history.md ]]; then
        return 0
    fi

    if [[ "$filename" == *"更新记录"* || "$filename" == *"变更记录"* || "$filename" == *"版本记录"* || "$filename" == *"更新日志"* || "$filename" == *"发布记录"* ]]; then
        return 0
    fi
    return 1
}

# 判断 PDF 是否应该跳过。
# 当前 Cloudflare Pages 发布策略：所有 PDF 一律不发布，避免单文件大小限制和旧资源残留导致部署失败。
should_skip_pdf() {
    local file="$1"
    local rel_path

    rel_path="${file#$ROOT_DIR/}"

    log "Skipped PDF: $rel_path 已按发布策略排除。"
    return 0
}

# 收集指定目录直属的可发布 Markdown 文件。
collect_direct_publishable_markdown_files() {
    local dir="$1"
    local file
    local tmp_file

    PUBLISHABLE_MARKDOWN_FILES=()
    tmp_file="$(mktemp "${TMPDIR:-/tmp}/jobsdocs_md.XXXXXX")"

    find "$dir" -maxdepth 1 -type f -name "*.md" -print0 > "$tmp_file"

    while IFS= read -r -d '' file; do
        if should_skip_markdown "$file"; then
            continue
        fi

        PUBLISHABLE_MARKDOWN_FILES+=("$file")
    done < "$tmp_file"

    rm -f "$tmp_file"
}

# 收集指定目录直属的可发布 PDF 文件。
collect_direct_publishable_pdf_files() {
    local dir="$1"
    local file
    local tmp_file

    PUBLISHABLE_PDF_FILES=()
    tmp_file="$(mktemp "${TMPDIR:-/tmp}/jobsdocs_pdf.XXXXXX")"

    find "$dir" -maxdepth 1 -type f -iname "*.pdf" -print0 > "$tmp_file"

    while IFS= read -r -d '' file; do
        if should_skip_pdf "$file"; then
            continue
        fi

        PUBLISHABLE_PDF_FILES+=("$file")
    done < "$tmp_file"

    rm -f "$tmp_file"
}

# 判断指定目录直属层级是否包含可发布 Markdown 文件。
dir_has_publishable_markdown() {
    local dir="$1"

    collect_direct_publishable_markdown_files "$dir"

    [[ "${#PUBLISHABLE_MARKDOWN_FILES[@]}" -gt 0 ]]
}

# 收集指定目录直属子目录。
collect_direct_child_directories() {
    local dir="$1"
    local child_dir
    local tmp_file

    CHILD_DIRECTORIES=()
    tmp_file="$(mktemp "${TMPDIR:-/tmp}/jobsdocs_dirs.XXXXXX")"

    find "$dir" -maxdepth 1 -mindepth 1 -type d -print0 > "$tmp_file"

    while IFS= read -r -d '' child_dir; do
        CHILD_DIRECTORIES+=("$child_dir")
    done < "$tmp_file"

    rm -f "$tmp_file"
}

# 复制 assets 资源。
# Cloudflare Pages 构建环境不保证存在 rsync，所以这里使用 macOS / Linux 都自带的 cp。
copy_assets() {
    local source_dir="$1"
    local target_dir="$2"

    if [[ ! -d "$source_dir/assets" ]]; then
        return
    fi

    rm -rf "$target_dir/assets"
    mkdir -p "$target_dir/assets"

    cp -R "$source_dir/assets/." "$target_dir/assets/"
}

# 复制直属 PDF。
# 当前发布策略：PDF 全部排除，所以这里保持空实现。
copy_same_dir_pdfs() {
    return
}

# 写入单个 Markdown 正文，移除 front matter、首个标题和 [toc]。
write_single_markdown_body() {
    local source_file="$1"

    awk '
        BEGIN {
            removed_first_heading = 0
            in_front_matter = 0
            in_code_block = 0
        }

        NR == 1 {
            if ($0 == "---" || $0 == "+++") {
                in_front_matter = 1
                front_matter_marker = $0
                next
            }
        }

        in_front_matter == 1 {
            if ($0 == front_matter_marker) {
                in_front_matter = 0
            }

            next
        }

        /^[[:space:]]*```/ || /^[[:space:]]*~~~/ {
            in_code_block = !in_code_block
            print
            next
        }

        {
            line = $0
            lower_line = tolower(line)

            if (in_code_block == 0 && removed_first_heading == 0 && line ~ /^#{1,6}[[:space:]]*.*/) {
                removed_first_heading = 1
                next
            }

            if (in_code_block == 0 && lower_line ~ /^[[:space:]]*\[toc\][[:space:]]*$/) {
                next
            }

            print line
        }
    ' "$source_file" | normalize_markdown_body
}

# 写入 Markdown 页面 front matter。
# 注意：这里只写 front matter，不再额外写入 "# title"。
# Hugo Book 会自动渲染页面标题；如果这里再写一次，就会出现两个主标题。
write_markdown_page_header() {
    local target_file="$1"
    local title="$2"
    local date_value="$3"
    local weight_value="$4"
    local summary_source="$5"
    local safe_title
    local summary
    local safe_summary

    safe_title="$(escape_yaml_string "$title")"
    summary="$(get_summary "$summary_source")"
    safe_summary="$(escape_yaml_string "$summary")"

    {
        echo "---"
        echo "title: \"$safe_title\""
        echo "date: $date_value"
        echo "draft: false"
        echo "weight: $weight_value"
        echo "summary: \"$safe_summary\""
        echo "bookCollapseSection: false"
        echo "---"
        echo
    } > "$target_file"
}

# 获取直属 Markdown 里的 README.md。
get_direct_readme_markdown_file() {
    local md_file

    for md_file in "${PUBLISHABLE_MARKDOWN_FILES[@]}"; do
        if is_readme_markdown "$md_file"; then
            printf '%s' "$md_file"
            return
        fi
    done
}

# 写入普通叶子目录页面。
write_normal_leaf_directory_page() {
    local source_dir="$1"
    local target_dir="$2"
    local title="$3"
    local date_value="$4"
    local weight_value="$5"
    local target_file
    local summary_source
    local md_file
    local md_title
    local md_fallback

    target_file="$target_dir/index.md"
    summary_source="${PUBLISHABLE_MARKDOWN_FILES[0]}"

    mkdir -p "$target_dir"

    write_markdown_page_header "$target_file" "$title" "$date_value" "$weight_value" "$summary_source"

    if [[ "${#PUBLISHABLE_MARKDOWN_FILES[@]}" -eq 1 ]]; then
        write_single_markdown_body "${PUBLISHABLE_MARKDOWN_FILES[0]}" >> "$target_file"
    else
        for md_file in "${PUBLISHABLE_MARKDOWN_FILES[@]}"; do
            md_fallback="$(get_file_title_fallback "$md_file")"
            md_title="$(get_title_from_markdown "$md_file" "$md_fallback")"

            {
                echo
                echo "## $md_title"
                echo
                write_single_markdown_body "$md_file"
                echo
            } >> "$target_file"
        done
    fi

    copy_assets "$source_dir" "$target_dir"
    copy_same_dir_pdfs "$source_dir" "$target_dir"
}

# 写入单个 Markdown 独立页面。
write_single_markdown_page() {
    local source_dir="$1"
    local md_file="$2"
    local target_dir="$3"
    local title="$4"
    local weight_value="$5"
    local date_value
    local target_file

    date_value="$(get_git_date "$md_file")"
    target_file="$target_dir/index.md"

    mkdir -p "$target_dir"

    write_markdown_page_header "$target_file" "$title" "$date_value" "$weight_value" "$md_file"
    write_single_markdown_body "$md_file" >> "$target_file"

    copy_assets "$source_dir" "$target_dir"
    copy_same_dir_pdfs "$source_dir" "$target_dir"
}

# 写入普通 section 的 _index.md。
# 这种 section 只代表目录容器，本身没有 md 正文，所以左侧菜单里不允许点击进入。
write_section_index() {
    local target_dir="$1"
    local title="$2"
    local weight_value="$3"
    local safe_title

    safe_title="$(escape_yaml_string "$title")"

    mkdir -p "$target_dir"

    cat > "$target_dir/_index.md" <<EOF
---
title: "$safe_title"
weight: $weight_value
bookCollapseSection: false
jobsContainerOnly: true
---

EOF

    record_container_route "$target_dir"
}

# 如果当前页面下面还有子目录，则把 leaf bundle 的 index.md 提升为 branch bundle 的 _index.md。
# Hugo 只有 _index.md 才允许在左侧菜单里继续展示下级页面。
promote_leaf_page_to_branch_index() {
    local target_dir="$1"

    if [[ -f "$target_dir/index.md" ]]; then
        mv "$target_dir/index.md" "$target_dir/_index.md"
        log "Promoted Leaf Page To Branch Index: ${target_dir#$BLOG_DIR/}/_index.md"
    fi
}

# 写入 PDF 文档页。
# 当前不会被调用；保留函数是为了以后如果恢复 PDF 发布策略，可以少改结构。
write_pdf_page() {
    local source_pdf="$1"
    local target_dir="$2"
    local title="$3"
    local date_value="$4"
    local weight_value="$5"
    local pdf_filename
    local safe_title

    pdf_filename="$(basename "$source_pdf")"
    safe_title="$(escape_yaml_string "$title")"

    mkdir -p "$target_dir"
    cp "$source_pdf" "$target_dir/$pdf_filename"

    cat > "$target_dir/index.md" <<EOF
---
title: "$safe_title"
date: $date_value
draft: false
weight: $weight_value
bookCollapseSection: false
---

[打开 PDF](./$pdf_filename)

<object data="./$pdf_filename" type="application/pdf" width="100%" height="900px">
  <p>当前浏览器无法直接预览 PDF，请点击上面的链接打开。</p>
</object>
EOF
}

# 计算 .md 包裹目录对应的主页面目录。
get_markdown_named_main_target_dir() {
    local source_dir="$1"
    local visible_parent_target_dir="$2"
    local transparent_prefix="$3"
    local wrapper_title
    local readme_file
    local first_md_file
    local first_md_fallback
    local first_md_title
    local page_title
    local page_dirname

    collect_direct_publishable_markdown_files "$source_dir"

    wrapper_title="$(get_dir_title "$source_dir")"
    readme_file="$(get_direct_readme_markdown_file)"

    if [[ -n "$readme_file" ]]; then
        page_title="$(join_title_prefix "$transparent_prefix" "$wrapper_title")"
    elif [[ "${#PUBLISHABLE_MARKDOWN_FILES[@]}" -eq 1 ]]; then
        first_md_file="${PUBLISHABLE_MARKDOWN_FILES[0]}"
        first_md_fallback="$(get_file_title_fallback "$first_md_file")"
        first_md_title="$(get_title_from_markdown "$first_md_file" "$first_md_fallback")"
        page_title="$first_md_title"
    else
        page_title="$(join_title_prefix "$transparent_prefix" "$wrapper_title")"
    fi

    page_dirname="$(make_safe_path_segment "$page_title")"

    printf '%s/%s' "$visible_parent_target_dir" "$page_dirname"
}

# 同步 .md 包裹目录里的直属 Markdown。
# 如果有 README.md，则 README.md 成为这个包裹目录的主页面。
# 其他 Markdown 会成为主页面下面的下一级页面。
sync_markdown_named_leaf_directory() {
    local source_dir="$1"
    local visible_parent_target_dir="$2"
    local transparent_prefix="$3"
    local wrapper_title
    local readme_file
    local main_target_dir
    local md_file
    local md_fallback
    local md_title
    local page_title
    local page_dirname
    local target_dir

    collect_direct_publishable_markdown_files "$source_dir"

    wrapper_title="$(get_dir_title "$source_dir")"
    readme_file="$(get_direct_readme_markdown_file)"
    main_target_dir="$(get_markdown_named_main_target_dir "$source_dir" "$visible_parent_target_dir" "$transparent_prefix")"

    if [[ -n "$readme_file" ]]; then
        page_title="$(join_title_prefix "$transparent_prefix" "$wrapper_title")"

        write_single_markdown_page "$source_dir" "$readme_file" "$main_target_dir" "$page_title" "$WEIGHT_VALUE"

        log "Synced README Wrapper Page: ${readme_file#$ROOT_DIR/} -> ${main_target_dir#$BLOG_DIR/}/index.md"

        WEIGHT_VALUE=$((WEIGHT_VALUE + 10))
    fi

    for md_file in "${PUBLISHABLE_MARKDOWN_FILES[@]}"; do
        if is_readme_markdown "$md_file"; then
            continue
        fi

        md_fallback="$(get_file_title_fallback "$md_file")"
        md_title="$(get_title_from_markdown "$md_file" "$md_fallback")"

        if [[ -z "$readme_file" && "${#PUBLISHABLE_MARKDOWN_FILES[@]}" -eq 1 ]]; then
            target_dir="$main_target_dir"
        elif [[ -n "$readme_file" ]]; then
            page_dirname="$(make_safe_path_segment "$md_title")"
            target_dir="$main_target_dir/$page_dirname"
        else
            page_dirname="$(make_safe_path_segment "$md_title")"
            target_dir="$visible_parent_target_dir/$page_dirname"
        fi

        write_single_markdown_page "$source_dir" "$md_file" "$target_dir" "$md_title" "$WEIGHT_VALUE"

        log "Synced Wrapper Markdown Page: ${md_file#$ROOT_DIR/} -> ${target_dir#$BLOG_DIR/}/index.md"

        WEIGHT_VALUE=$((WEIGHT_VALUE + 10))
    done
}

# 同步普通叶子目录。
sync_normal_leaf_directory() {
    local source_dir="$1"
    local visible_parent_target_dir="$2"
    local transparent_prefix="$3"
    local dir_title
    local page_title
    local page_dirname
    local target_dir
    local date_value

    collect_direct_publishable_markdown_files "$source_dir"

    dir_title="$(get_dir_title "$source_dir")"
    page_title="$(join_title_prefix "$transparent_prefix" "$dir_title")"
    page_dirname="$(make_safe_path_segment "$page_title")"
    target_dir="$visible_parent_target_dir/$page_dirname"
    date_value="$(get_git_date "${PUBLISHABLE_MARKDOWN_FILES[0]}")"

    write_normal_leaf_directory_page "$source_dir" "$target_dir" "$page_title" "$date_value" "$WEIGHT_VALUE"

    log "Synced Leaf Directory: ${source_dir#$ROOT_DIR/} -> ${target_dir#$BLOG_DIR/}/index.md"

    WEIGHT_VALUE=$((WEIGHT_VALUE + 10))
}

# 获取普通叶子目录同步后的目标目录。
get_normal_leaf_target_dir() {
    local source_dir="$1"
    local visible_parent_target_dir="$2"
    local transparent_prefix="$3"
    local dir_title
    local page_title
    local page_dirname

    dir_title="$(get_dir_title "$source_dir")"
    page_title="$(join_title_prefix "$transparent_prefix" "$dir_title")"
    page_dirname="$(make_safe_path_segment "$page_title")"

    printf '%s/%s' "$visible_parent_target_dir" "$page_dirname"
}

# 同步普通目录直属 PDF。
# 当前发布策略：PDF 全部排除，所以这里保持空实现。
sync_direct_pdfs_as_pages() {
    return
}


# jobsdocs-v17-descendant-markdown-start
# 判断目录树下面是否存在任何可发布 Markdown。
# 用于处理这种通用结构：
#   A.md/
#     B.md/
#       B.md
#     C.md/
#       C.md
#
# 即使 A.md 自己没有直属 Markdown，它也应该作为可展开节点保留下来。
dir_has_publishable_markdown_descendant() {
    local dir="$1"
    local file
    local tmp_file

    tmp_file="$(mktemp "${TMPDIR:-/tmp}/jobsdocs_desc_md.XXXXXX")"
    find "$dir" -type f -name "*.md" -print0 > "$tmp_file"

    while IFS= read -r -d '' file; do
        if should_skip_markdown "$file"; then
            continue
        fi

        rm -f "$tmp_file"
        return 0
    done < "$tmp_file"

    rm -f "$tmp_file"
    return 1
}
# jobsdocs-v17-descendant-markdown-end

# 递归同步目录。
# 核心规则：
# 1. 根目录下的一级目录可以作为分类标题。
# 2. 非一级目录如果没有直属 Markdown，不生成标题，而是把目录名合并进后续内容标题。
# 3. *.md 结尾且直属有 Markdown 的目录是包裹目录。
# 4. 包裹目录如果有 README.md，README.md 是主页面。
# 5. 已经生成页面的目录，仍然继续扫描它下面的子目录，形成下一级标题。
process_directory() {
    local source_dir="$1"
    local visible_parent_target_dir="$2"
    local transparent_prefix="$3"
    local is_top_level="$4"
    local child_dir
    local dir_title
    local section_target_dir
    local next_visible_parent_target_dir
    local next_transparent_prefix
    local child_title
    local has_markdown="false"

    if should_skip_directory "$source_dir"; then
        return
    fi

    if [[ "$source_dir" == "$ROOT_DIR" ]]; then
        sync_direct_pdfs_as_pages "$source_dir" "$CONTENT_DIR" ""

        collect_direct_child_directories "$source_dir"

        for child_dir in "${CHILD_DIRECTORIES[@]}"; do
            process_directory "$child_dir" "$CONTENT_DIR" "" "true"
        done

        return
    fi

    if dir_has_publishable_markdown "$source_dir"; then
        has_markdown="true"
    fi

    if [[ "$has_markdown" == "true" ]]; then
        if is_markdown_named_dir_segment "$(basename "$source_dir")"; then
            sync_markdown_named_leaf_directory "$source_dir" "$visible_parent_target_dir" "$transparent_prefix"
            next_visible_parent_target_dir="$(get_markdown_named_main_target_dir "$source_dir" "$visible_parent_target_dir" "$transparent_prefix")"
            next_transparent_prefix=""
        else
            sync_normal_leaf_directory "$source_dir" "$visible_parent_target_dir" "$transparent_prefix"
            next_visible_parent_target_dir="$(get_normal_leaf_target_dir "$source_dir" "$visible_parent_target_dir" "$transparent_prefix")"
            next_transparent_prefix=""
        fi

        collect_direct_child_directories "$source_dir"

        if [[ "${#CHILD_DIRECTORIES[@]}" -gt 0 ]]; then
            promote_leaf_page_to_branch_index "$next_visible_parent_target_dir"
        fi

        for child_dir in "${CHILD_DIRECTORIES[@]}"; do
            process_directory "$child_dir" "$next_visible_parent_target_dir" "$next_transparent_prefix" "false"
        done

        return
    fi

    if [[ "$is_top_level" == "true" ]] || { is_markdown_named_dir_segment "$(basename "$source_dir")" && dir_has_publishable_markdown_descendant "$source_dir"; }; then
        dir_title="$(get_dir_title "$source_dir")"
        section_target_dir="$visible_parent_target_dir/$(make_safe_path_segment "$dir_title")"

        write_section_index "$section_target_dir" "$dir_title" "$WEIGHT_VALUE"

        log "Synced Top Section: ${source_dir#$ROOT_DIR/} -> ${section_target_dir#$BLOG_DIR/}/_index.md"

        WEIGHT_VALUE=$((WEIGHT_VALUE + 10))

        next_visible_parent_target_dir="$section_target_dir"
        next_transparent_prefix=""
    else
        child_title="$(get_dir_title "$source_dir")"
        next_visible_parent_target_dir="$visible_parent_target_dir"
        next_transparent_prefix="$(join_title_prefix "$transparent_prefix" "$child_title")"
    fi

    sync_direct_pdfs_as_pages "$source_dir" "$next_visible_parent_target_dir" "$next_transparent_prefix"

    collect_direct_child_directories "$source_dir"

    for child_dir in "${CHILD_DIRECTORIES[@]}"; do
        process_directory "$child_dir" "$next_visible_parent_target_dir" "$next_transparent_prefix" "false"
    done
}

# 同步根目录直属 Markdown。
sync_root_markdown_files() {
    local md_file
    local md_fallback
    local md_title
    local target_dir
    local page_dirname

    collect_direct_publishable_markdown_files "$ROOT_DIR"

    for md_file in "${PUBLISHABLE_MARKDOWN_FILES[@]}"; do
        md_fallback="$(get_file_title_fallback "$md_file")"
        md_title="$(get_title_from_markdown "$md_file" "$md_fallback")"
        page_dirname="$(make_safe_path_segment "$md_title")"
        target_dir="$CONTENT_DIR/$page_dirname"

        write_single_markdown_page "$ROOT_DIR" "$md_file" "$target_dir" "$md_title" "$WEIGHT_VALUE"

        log "Synced Root Markdown: ${md_file#$ROOT_DIR/} -> ${target_dir#$BLOG_DIR/}/index.md"

        WEIGHT_VALUE=$((WEIGHT_VALUE + 10))
    done
}

# 清空 Hugo 生成产物目录。
# Cloudflare Pages 会校验 public 目录；如果这里残留旧 PDF，哪怕本次脚本跳过 PDF，部署也会失败。
clean_public_dir() {
    rm -rf "$BLOG_DIR/public"
}

# 清空 Hugo 自动同步生成的 docs 内容目录。
clean_content_dir() {
    mkdir -p "$CONTENT_DIR"
    find "$CONTENT_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
}

# 清理旧 PaperMod posts 内容。
clean_obsolete_posts_dir() {
    if [[ -d "$OBSOLETE_POSTS_DIR" ]]; then
        rm -rf "$OBSOLETE_POSTS_DIR"
    fi
}

# 创建 docs 根首页。
# 不写 "# Jobs Docs"，避免 Hugo Book 自动标题之外再多一个主标题。
ensure_docs_index() {
    mkdir -p "$CONTENT_DIR"

    cat > "$CONTENT_DIR/_index.md" <<'EOF'
---
title: "Jobs Docs"
weight: 1
bookCollapseSection: false
---

EOF
}

# 检查站点静态图标。
# 图标固定使用 Hugo 项目内的 static/icon.png。
# 不再从 JobsDocs 根目录复制 icon.png，避免本地和线上图标来源不一致。
sync_site_static_assets() {
    local icon_file="$BLOG_DIR/static/icon.png"

    if [[ -f "$icon_file" ]]; then
        log "Using site icon: $icon_file"
    else
        log "Warning: $icon_file 不存在，左上角图标可能无法显示。"
    fi
}

# 检查依赖命令。
check_dependencies() {
    local missing_count=0

    if ! command -v git >/dev/null 2>&1; then
        log_error "git 未安装。"
        missing_count=$((missing_count + 1))
    fi

    if ! command -v awk >/dev/null 2>&1; then
        log_error "awk 未安装。"
        missing_count=$((missing_count + 1))
    fi

    if ! command -v sed >/dev/null 2>&1; then
        log_error "sed 未安装。"
        missing_count=$((missing_count + 1))
    fi

    if ! command -v grep >/dev/null 2>&1; then
        log_error "grep 未安装。"
        missing_count=$((missing_count + 1))
    fi

    if [[ "$missing_count" -gt 0 ]]; then
        exit 1
    fi
}


# jobsdocs-v12-runtime-start
ensure_jobsdocs_v12_runtime() {
    mkdir -p "$BLOG_DIR/static"

    local jobsdocs_commit=""

    if command -v git >/dev/null 2>&1; then
        jobsdocs_commit="$(git -C "$ROOT_DIR" rev-parse --short=7 HEAD 2>/dev/null || true)"
    fi

    if [[ -z "$jobsdocs_commit" && -n "${CF_PAGES_COMMIT_SHA:-}" ]]; then
        jobsdocs_commit="$(printf '%.7s' "$CF_PAGES_COMMIT_SHA")"
    fi

    if [[ -z "$jobsdocs_commit" && -n "${GITHUB_SHA:-}" ]]; then
        jobsdocs_commit="$(printf '%.7s' "$GITHUB_SHA")"
    fi

    if [[ -z "$jobsdocs_commit" ]]; then
        jobsdocs_commit="unknown"
    fi

    jobsdocs_commit="$(printf '%s' "$jobsdocs_commit" | sed 's/[^0-9A-Za-z_.-]/_/g' | cut -c1-7)"

    cat > "$BLOG_DIR/static/jobs-git-version.js" <<EOF
window.JOBS_DOCS_GIT_VERSION = "$jobsdocs_commit";
EOF

    cat >> "$BODY_INJECTION_FILE" <<'EOF'

<!-- jobsdocs-v12-runtime -->
<script src="{{ "jobs-git-version.js" | relURL }}?v={{ now.Unix }}"></script>
<script>
(function () {
  function postToShell(type, reason) {
    try {
      if (window.parent && window.parent !== window) {
        window.parent.postMessage(
          {
            type: type,
            reason: reason || type
          },
          window.location.origin
        );
      }
    } catch (error) {}
  }

  function ensureGitVersionLabel() {
    var brand = document.querySelector(".book-brand");

    if (!brand) {
      return;
    }

    var version = String(window.JOBS_DOCS_GIT_VERSION || "unknown").slice(0, 7);
    var label = document.querySelector(".jobs-git-version");

    if (!label) {
      label = document.createElement("div");
      label.className = "jobs-git-version";
      brand.insertAdjacentElement("afterend", label);
    }

    label.textContent = "@" + version;
  }

  function hookMenuScroll() {
    document.querySelectorAll(".book-menu, .book-menu-content").forEach(function (element) {
      if (element.__jobsDocsV12MenuScrollHooked) {
        return;
      }

      element.__jobsDocsV12MenuScrollHooked = true;

      element.addEventListener("scroll", function () {
        postToShell("jobsdocs:menu-scroll", "menu-scroll");
      }, { passive: true });
    });
  }

  function hookUserActionUnlock() {
    [
      "click",
      "pointerdown",
      "pointerup",
      "touchstart",
      "touchmove",
      "touchend",
      "mousedown",
      "mouseup",
      "keydown",
      "wheel",
      "scroll"
    ].forEach(function (eventName) {
      document.addEventListener(eventName, function () {
        postToShell("jobsdocs:any-user-action", eventName);
        postToShell("jobsdocs:unlock-music", eventName);
      }, { capture: true, passive: true });
    });
  }

  function boot() {
    ensureGitVersionLabel();
    hookMenuScroll();
    postToShell("jobsdocs:layout-change", "boot");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }

  window.addEventListener("load", boot);
  window.addEventListener("resize", function () {
    boot();
    postToShell("jobsdocs:layout-change", "resize");
  });

  window.addEventListener("orientationchange", function () {
    window.setTimeout(function () {
      boot();
      postToShell("jobsdocs:layout-change", "orientationchange");
    }, 180);

    window.setTimeout(function () {
      boot();
      postToShell("jobsdocs:layout-change", "orientationchange-late");
    }, 420);
  });

  hookUserActionUnlock();
})();
</script>
<!-- /jobsdocs-v12-runtime -->
EOF

    log "Git Version: $jobsdocs_commit"
}
# jobsdocs-v12-runtime-end










# jobsdocs-v18-panel-focus-runtime-start
ensure_jobsdocs_v18_panel_focus_runtime() {
    cat >> "$BODY_INJECTION_FILE" <<'EOF'

<!-- jobsdocs-v18-panel-focus-runtime -->
<script>
(function () {
  var lastNotifyAt = 0;
  var shield = null;
  var lastHeaderToggleAt = 0;
  var lastHeaderToggleWhich = "";

  function postToParent(type, reason) {
    try {
      if (window.parent && window.parent !== window) {
        window.parent.postMessage({ type: type, reason: reason || type }, window.location.origin);
      }
    } catch (error) {}
  }

  function directParentPlay(reason) {
    try {
      if (window.parent && window.parent !== window && typeof window.parent.JobsDocsTryPlayMusic === "function") {
        window.parent.JobsDocsTryPlayMusic("iframe:" + reason, true);
      }
    } catch (error) {}
  }

  function unlockMusic(reason, force) {
    var now = Date.now();
    if (!force && now - lastNotifyAt < 100) return;
    lastNotifyAt = now;

    directParentPlay(reason);
    postToParent("jobsdocs:any-user-action", reason);
    postToParent("jobsdocs:unlock-music", reason);
  }

  function menuControl() {
    return document.getElementById("menu-control");
  }

  function tocControl() {
    return document.getElementById("toc-control");
  }

  function menuButton() {
    return document.querySelector('label[for="menu-control"]');
  }

  function tocButton() {
    return document.querySelector('label[for="toc-control"]');
  }

  function isLeftOpen() {
    var control = menuControl();
    return !!(control && control.checked);
  }

  function isRightOpen() {
    var control = tocControl();
    return !!(control && control.checked);
  }

  function activePanel() {
    if (isLeftOpen()) return document.querySelector(".book-menu");
    if (isRightOpen()) return document.querySelector(".book-toc");
    return null;
  }

  function normalizeTarget(target) {
    if (!target) return null;
    if (target.nodeType !== 1) return target.parentElement;
    return target;
  }

  function isInsidePanel(target) {
    target = normalizeTarget(target);
    return !!(target && target.closest && target.closest(".book-menu, .book-toc"));
  }

  function isInsideActivePanel(target) {
    target = normalizeTarget(target);
    var panel = activePanel();
    return !!(target && panel && panel.contains(target));
  }

  function isHeaderControl(target) {
    target = normalizeTarget(target);
    return !!(target && target.closest && target.closest('label[for="menu-control"], label[for="toc-control"]'));
  }

  function panelLink(target) {
    target = normalizeTarget(target);
    if (!target || !target.closest) return null;
    return target.closest(".book-menu a, .book-toc a");
  }

  function ensureShield() {
    if (shield && shield.parentNode) return shield;

    shield = document.createElement("div");
    shield.className = "jobs-panel-touch-shield";
    shield.setAttribute("aria-hidden", "true");

    ["click", "pointerdown", "touchstart", "wheel"].forEach(function (eventName) {
      shield.addEventListener(eventName, function (event) {
        unlockMusic("shield:" + eventName, true);
        closePanels("shield-close");

        if (event.cancelable) event.preventDefault();
        event.stopPropagation();
      }, { capture: true, passive: eventName !== "touchstart" && eventName !== "wheel" });
    });

    document.body.appendChild(shield);
    return shield;
  }

  function removeShield() {
    if (shield && shield.parentNode) shield.parentNode.removeChild(shield);
  }

  function focusPanel() {
    var panel = activePanel();
    if (!panel) return;

    if (!panel.hasAttribute("tabindex")) panel.setAttribute("tabindex", "-1");

    try {
      panel.focus({ preventScroll: true });
    } catch (error) {
      try { panel.focus(); } catch (_) {}
    }
  }

  function syncPanelState() {
    var leftOpen = isLeftOpen();
    var rightOpen = isRightOpen();
    var anyOpen = leftOpen || rightOpen;

    document.documentElement.classList.toggle("jobs-panel-open", anyOpen);
    document.body.classList.toggle("jobs-panel-open", anyOpen);
    document.documentElement.classList.toggle("jobs-left-panel-open", leftOpen);
    document.body.classList.toggle("jobs-left-panel-open", leftOpen);
    document.documentElement.classList.toggle("jobs-right-panel-open", rightOpen);
    document.body.classList.toggle("jobs-right-panel-open", rightOpen);

    if (anyOpen) {
      ensureShield();
      window.setTimeout(focusPanel, 0);
    } else {
      removeShield();
    }

    postToParent("jobsdocs:layout-change", anyOpen ? "panel-open" : "panel-close");
  }

  function closePanels(reason) {
    var left = menuControl();
    var right = tocControl();

    if (left) left.checked = false;
    if (right) right.checked = false;

    syncPanelState();
    unlockMusic(reason || "close-panels", true);
  }

  function togglePanel(which, reason) {
    var left = menuControl();
    var right = tocControl();

    if (which === "left") {
      if (!left) return;

      var nextLeft = !left.checked;
      left.checked = nextLeft;

      if (right) right.checked = false;
    }

    if (which === "right") {
      if (!right) return;

      var nextRight = !right.checked;
      right.checked = nextRight;

      if (left) left.checked = false;
    }

    syncPanelState();
    unlockMusic(reason || ("toggle-" + which), true);
  }

  function handleHeaderToggle(event, which) {
    if (event.cancelable) event.preventDefault();
    event.stopPropagation();
    if (event.stopImmediatePropagation) event.stopImmediatePropagation();

    var now = Date.now();
    if (lastHeaderToggleWhich === which && now - lastHeaderToggleAt < 260) {
      unlockMusic("duplicate-header-" + which, true);
      return;
    }

    lastHeaderToggleAt = now;
    lastHeaderToggleWhich = which;

    togglePanel(which, which + "-header-toggle");
  }

  function hookHeaderButtons() {
    var leftButton = menuButton();
    var rightButton = tocButton();

    if (leftButton && !leftButton.__jobsDocsV18ManualToggleHooked) {
      leftButton.__jobsDocsV18ManualToggleHooked = true;
      leftButton.setAttribute("role", "button");
      leftButton.setAttribute("tabindex", "0");

      ["click", "pointerup", "touchend"].forEach(function (eventName) {
        leftButton.addEventListener(eventName, function (event) {
          handleHeaderToggle(event, "left");
        }, true);
      });

      leftButton.addEventListener("keydown", function (event) {
        if (event.key === "Enter" || event.key === " ") {
          handleHeaderToggle(event, "left");
        }
      }, true);
    }

    if (rightButton && !rightButton.__jobsDocsV18ManualToggleHooked) {
      rightButton.__jobsDocsV18ManualToggleHooked = true;
      rightButton.setAttribute("role", "button");
      rightButton.setAttribute("tabindex", "0");

      ["click", "pointerup", "touchend"].forEach(function (eventName) {
        rightButton.addEventListener(eventName, function (event) {
          handleHeaderToggle(event, "right");
        }, true);
      });

      rightButton.addEventListener("keydown", function (event) {
        if (event.key === "Enter" || event.key === " ") {
          handleHeaderToggle(event, "right");
        }
      }, true);
    }
  }

  function hookPanelLinks() {
    document.querySelectorAll(".book-menu a, .book-toc a").forEach(function (link) {
      if (link.__jobsDocsV18PanelLinkHooked) return;

      link.__jobsDocsV18PanelLinkHooked = true;

      link.addEventListener("click", function () {
        unlockMusic("panel-link-click", true);

        window.setTimeout(function () {
          closePanels("panel-link-close");
        }, 0);
      }, false);
    });
  }

  function hookPanelScroll() {
    document.querySelectorAll(".book-menu, .book-menu-content, .book-toc, .book-toc-content, .book-toc nav").forEach(function (element) {
      if (element.__jobsDocsV18PanelScrollHooked) return;

      element.__jobsDocsV18PanelScrollHooked = true;
      element.addEventListener("scroll", function () {
        unlockMusic("panel-scroll", true);
        postToParent("jobsdocs:panel-scroll", "panel-scroll");
      }, { passive: true });
    });
  }

  function backgroundGuard(event) {
    var strong = /touchstart|pointerdown|mousedown|click|keydown/.test(event.type);
    unlockMusic(event.type, strong);

    if (!isLeftOpen() && !isRightOpen()) return;

    if (isHeaderControl(event.target)) return;

    var link = panelLink(event.target);
    if (link && isInsideActivePanel(link)) {
      return;
    }

    if (isInsideActivePanel(event.target) || isInsidePanel(event.target)) {
      return;
    }

    closePanels("outside-" + event.type);

    if (event.cancelable) event.preventDefault();
    event.stopPropagation();
  }

  function bindBackgroundGuards() {
    if (document.__jobsDocsV18BackgroundGuardsHooked) return;
    document.__jobsDocsV18BackgroundGuardsHooked = true;

    ["pointerdown", "touchstart", "click", "wheel", "touchmove"].forEach(function (eventName) {
      document.addEventListener(eventName, backgroundGuard, { capture: true, passive: false });
    });
  }

  function bindAnyAction(target, label) {
    if (!target || target.__jobsDocsV18AnyActionHooked) return;
    target.__jobsDocsV18AnyActionHooked = true;

    ["click", "pointerdown", "pointerup", "touchstart", "touchmove", "touchend", "mousedown", "mouseup", "keydown", "wheel", "scroll"].forEach(function (eventName) {
      target.addEventListener(eventName, function () {
        var strong = /touchstart|pointerdown|mousedown|click|keydown/.test(eventName);
        unlockMusic(label + ":" + eventName, strong);
      }, { capture: true, passive: true });
    });
  }

  function boot() {
    hookHeaderButtons();
    hookPanelLinks();
    hookPanelScroll();
    bindBackgroundGuards();

    bindAnyAction(window, "window");
    bindAnyAction(document, "document");
    bindAnyAction(document.documentElement, "html");
    bindAnyAction(document.body, "body");

    document.querySelectorAll(".book-page, main, .book-menu, .book-menu-content, .book-toc, .book-toc-content").forEach(function (element) {
      bindAnyAction(element, element.className || element.tagName || "element");
    });

    syncPanelState();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }

  window.addEventListener("load", boot);
  window.addEventListener("pageshow", boot);
  window.addEventListener("resize", function () {
    boot();
    postToParent("jobsdocs:layout-change", "resize");
  });

  window.addEventListener("orientationchange", function () {
    window.setTimeout(boot, 180);
    window.setTimeout(boot, 420);
  });
})();
</script>
<!-- /jobsdocs-v18-panel-focus-runtime -->
EOF
}
# jobsdocs-v18-panel-focus-runtime-end

# 脚本主流程。
main() {
    # 1. 检查依赖命令。
    check_dependencies

    # 2. 打印关键目录。
    log "ROOT_DIR: $ROOT_DIR"
    log "BLOG_DIR: $BLOG_DIR"
    log "CONTENT_DIR: $CONTENT_DIR"

    # 3. 清空旧内容，并准备注入文件。
    clean_public_dir
    prepare_container_routes_file
    clean_content_dir
    clean_obsolete_posts_dir
    ensure_body_injection
    ensure_theme_runtime
    ensure_jobsdocs_v12_runtime
    ensure_jobsdocs_v18_panel_focus_runtime

    # 4. 创建 docs 根首页，并同步站点静态资源。
    ensure_docs_index
    sync_site_static_assets

    # 5. 同步根目录直属 Markdown。
    sync_root_markdown_files

    # 6. 从 JobsDocs 根目录开始递归同步目录。
    process_directory "$ROOT_DIR" "$CONTENT_DIR" "" "false"

    # 7. 输出最终状态。
    log "Done. Site content synced by folder-node rules."
}

main "$@"
