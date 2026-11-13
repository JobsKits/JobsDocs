#!/usr/bin/env bash
# 脚本自述：
# - 脚本名称：install.command
# - 核心用途：同步 JobsDocs 文档，并按运行模式生成 Hugo 站点或启动本地预览。
# - 影响范围：会重新生成 blog/content、blog/public 及相关 Hugo 运行文件。
# - 运行提示：终端默认等待确认后预览；传入 --ci 时无交互完成一次正式构建后退出。
# 仅渲染自述：标题红色加粗，编号正文蓝色常规字重；非彩色终端输出纯文本。
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

# JOBS_INPUT_CHOICE_STYLE_BEGIN
# 只展示提示选项；不读取答案、不改变默认值、返回码或业务环境。
jobs_prompt_color_ready() {
  [ -z "${NO_COLOR+x}" ] && [ -n "${TERM:-}" ] && [ "${TERM:-}" != dumb ] &&
    [ "${PLAIN_OUTPUT:-0}" != 1 ] && [ "${IS_SOURCETREE_RUNTIME:-0}" != 1 ]
}
# 原生 awk 分段着色；任意/非空输入优先，括号内外沿用同一个选项。
jobs_prompt_format() {
  /usr/bin/awk -v color="${1:-0}" -v lines="${2:-0}" -v keep="${3:-0}" '
    function typedEnter(value, start, prefix) {
      prefix = substr(value, 1, start - 1)
      gsub(/[“”‘’「」『』"]/, "", prefix)
      gsub(sprintf("%c", 39), "", prefix)
      if (prefix ~ /(空格|[Ss][Pp][Aa][Cc][Ee])[[:space:]]*(后|再|并|[Tt][Hh][Ee][Nn])?[[:space:]]*$/) return 1
      return prefix ~ /(输入|键入|填写|[Tt]ype)[^；;|]*[[:alnum:]_+-]+[[:space:]]*(后|再|并)?[[:space:]]*$/
    }
    function greenPosition(value, token, start) {
      if (match(value, /(直接|仅|只需|只|按下|按)?[[:space:]]*(回车|回車)/)) {
        start = RSTART
        return typedEnter(value, start) ? 0 : start
      }
      if (!match(value, /(^|[^[:alnum:]_])([Ee][Nn][Tt][Ee][Rr]|[Rr][Ee][Tt][Uu][Rr][Nn])([^[:alnum:]_]|$)/)) return 0
      start = RSTART
      token = substr(value, RSTART, RLENGTH)
      match(token, /[Ee][Nn][Tt][Ee][Rr]|[Rr][Ee][Tt][Uu][Rr][Nn]/)
      start += RSTART - 1
      return typedEnter(value, start) ? 0 : start
    }
    function segment(value, inherited, start, kind, prefix, body, red, green, connector, left, right, splitAt) {
      if (value == "") return value
      kind = inherited
      start = 1
      if (!kind) {
        if (match(value, /(输入)?(任意|任何)(非空)?(字符|内容|输入|键)|非空(字符|内容|输入)?|其它输入|其他输入|[Tt]ype (anything|any[^ ]*)|[Pp]ress any key/)) {
          red = RSTART
        }
        green = greenPosition(value)
        if (red && green && green < red) {
          left = substr(value, 1, red - 1)
          right = substr(value, red)
          connector = ""
          if (match(left, /(或者|或)[[:space:]]*$/)) {
            connector = substr(left, RSTART)
            left = substr(left, 1, RSTART - 1)
          }
          return segment(left, 0) connector segment(right, 31)
        }
        if (red && green && red < green && match(value, /或[[:space:]]*(直接|仅|只需|只|按下|按)?(回车|回車)/)) {
          splitAt = RSTART
          return segment(substr(value, 1, splitAt - 1), 31) "或" segment(substr(value, splitAt + length("或")), 0)
        }
        if (red) {
          kind = 31
          start = red
        } else if (green) {
          kind = 32
          start = green
        }
      }
      if (!kind || !color) return value
      prefix = substr(value, 1, start - 1)
      body = substr(value, start)
      return prefix esc "[1;" kind "m" body esc "[0m"
    }
    function render(value, output, part, boundary, inherited, kind, consumed, depth, original) {
      original = value
      gsub(esc "\\[[0-9;]*m", "", value)
      if (color && keep && !greenPosition(value) && value !~ /(任意|任何|非空|其它输入|其他输入|[Tt]ype (anything|any[^ ]*)|[Pp]ress any key)/) return original
      output = ""
      inherited = 0
      depth = 0
      while (match(value, /[；;\/|，,、？?：:=＝（）()\[\]【】]/)) {
        part = substr(value, 1, RSTART - 1)
        boundary = substr(value, RSTART, RLENGTH)
        consumed = RSTART + RLENGTH
        output = output segment(part, inherited) boundary
        if (boundary ~ /[（(\[【]/) {
          depth++
          if (part ~ /(任意|任何|非空|其它输入|其他输入|[Tt]ype (anything|any[^ ]*)|[Pp]ress any key)/) inherited = 31
          else if (greenPosition(part)) inherited = 32
        } else if (boundary ~ /[）)\]】]/) {
          if (depth) depth--
        } else if (boundary ~ /[：:=＝]/) {
          if (!inherited) {
            if (part ~ /(任意|任何|非空|其它输入|其他输入)/) inherited = 31
            else if (greenPosition(part)) inherited = 32
          }
        } else if (!depth) inherited = 0
        value = substr(value, consumed)
      }
      return output segment(value, inherited)
    }
    BEGIN { esc = sprintf("%c", 27); first = 1 }
    {
      if (lines == 2) {
        if (!first) printf "%s\n", render(pending)
        pending = $0
        first = 0
        next
      }
      if (!lines && !first) printf "\n"
      printf "%s", render($0)
      if (lines) printf "\n"
      first = 0
    }
    END {
      if (lines == 2 && !first) {
        sub(sprintf("%c", 1) "$", "", pending)
        printf "%s", render(pending)
      }
    }
  '
}
# read 的命令替换会使 stdout 成为管道，按输入与提示所在 stderr 判断终端。
jobs_prompt_render() {
  local jobs_prompt_color=0
  if [ -t 0 ] && [ -t 2 ] && jobs_prompt_color_ready; then jobs_prompt_color=1; fi
  printf "%s" "$1" | jobs_prompt_format "$jobs_prompt_color" 0
}
# 仅放在显示链末端；tee 在此函数之前接收纯文本，不把 ANSI 写入日志。
jobs_prompt_stream() {
  local jobs_prompt_color=0
  if [ -t 1 ] && jobs_prompt_color_ready; then jobs_prompt_color=1; fi
  jobs_prompt_format "$jobs_prompt_color" 1 1
}
# 显示管道保留原末尾换行；只删除本轮追加的最后一个结束标记。
jobs_prompt_filter() {
  local jobs_prompt_color=0
  if [ -t 1 ] && jobs_prompt_color_ready; then jobs_prompt_color=1; fi
  { /bin/cat; printf '\001'; } | jobs_prompt_format "$jobs_prompt_color" 2 1
}
# 仅包装原 printf/echo/print 展示，原参数、尾换行与显示命令退出码保持不变。
jobs_prompt_output() {
  local jobs_prompt_status=0 jobs_prompt_stderr=0 jobs_prompt_arg="" jobs_prompt_previous=""
  if [ "${1:-}" = print ]; then
    for jobs_prompt_arg in "$@"; do
      case "$jobs_prompt_arg" in -?*u2*|-u2) jobs_prompt_stderr=1 ;; esac
      if [ "$jobs_prompt_previous" = -u ] && [ "$jobs_prompt_arg" = 2 ]; then jobs_prompt_stderr=1; fi
      jobs_prompt_previous="$jobs_prompt_arg"
      [ "$jobs_prompt_arg" != -- ] || break
    done
  fi
  if [ -n "${ZSH_VERSION:-}" ]; then
    if [ "$jobs_prompt_stderr" = 1 ]; then
      "$@" 2>&1 | jobs_prompt_filter >&2
      jobs_prompt_status=$(( ${pipestatus[1]} != 0 ? ${pipestatus[1]} : ${pipestatus[2]} ))
    else
      "$@" | jobs_prompt_filter
      jobs_prompt_status=$(( ${pipestatus[1]} != 0 ? ${pipestatus[1]} : ${pipestatus[2]} ))
    fi
  elif [ -n "${BASH_VERSION:-}" ]; then
    "$@" | jobs_prompt_filter
    jobs_prompt_status=$(( ${PIPESTATUS[0]} != 0 ? ${PIPESTATUS[0]} : ${PIPESTATUS[1]} ))
  else
    "$@" | jobs_prompt_filter
    jobs_prompt_status=$?
  fi
  return "$jobs_prompt_status"
}
# 仅替换日志 primitive 的 tee：磁盘同步追加纯文，终端保留非选项原色。
jobs_prompt_tee() {
  local jobs_prompt_log="$1" jobs_prompt_line="" jobs_prompt_newline=0
  while :; do
    jobs_prompt_line=""
    if IFS= read -r jobs_prompt_line; then jobs_prompt_newline=1; else jobs_prompt_newline=0; [ -n "$jobs_prompt_line" ] || break; fi
    if [ "$jobs_prompt_newline" = 1 ]; then
      { printf '%s\n' "$jobs_prompt_line"; printf '\001'; } | jobs_prompt_format 0 2 >> "$jobs_prompt_log" || return $?
      printf '%s\n' "$jobs_prompt_line" | jobs_prompt_filter || return $?
    else
      { printf '%s' "$jobs_prompt_line"; printf '\001'; } | jobs_prompt_format 0 2 >> "$jobs_prompt_log" || return $?
      printf '%s' "$jobs_prompt_line" | jobs_prompt_filter || return $?
    fi
  done
}
# JOBS_INPUT_CHOICE_STYLE_END

jobs_intro_style() {
  local intro_color=0
  if [ -t 1 ] && [ -n "${TERM:-}" ] && [ "${TERM:-}" != dumb ] &&
     [ -z "${NO_COLOR+x}" ] && [ "${PLAIN_OUTPUT:-0}" != 1 ] &&
     [ "${IS_SOURCETREE_RUNTIME:-0}" != 1 ]; then
    intro_color=1
  fi
  /usr/bin/awk -v color="$intro_color" -v role="${1:-body}" '
    BEGIN { esc = sprintf("%c", 27) }
    {
      gsub(esc "\\[[0-9;]*m", "")
      gsub(/\\(033|e|x1[bB])\[[0-9;]*m/, "")
      if (!color || $0 ~ /^[[:space:]]*$/) { print; next }
      numbered = ($0 ~ /^[[:space:]➤ℹ🔹✔⚠]*([0-9]+[、.)）]|[0-9]+️⃣|[-•])/)
      heading = ($0 ~ /^[[:space:]]*#{1,6}[[:space:]]/ || $0 ~ /[：:][[:space:]]*$/ || $0 ~ /^[[:space:]]*[=━─-]{3}/)
      title = (!numbered && (role == "title" || heading))
      if (role == "auto" && !seen && !numbered) title = 1
      if ($0 !~ /^[[:space:]]*[=━─-]+[[:space:]]*$/) seen = 1
      printf "%s%s%s\n", esc (title ? "[1;31m" : "[0;34m"), $0, esc "[0m"
    }
  '
}
set -euo pipefail

SCRIPT_BASENAME="${0##*/}"
SCRIPT_BASENAME="${SCRIPT_BASENAME%.*}"
LOG_FILE="${TMPDIR:-/tmp}/${SCRIPT_BASENAME}.log"

SCRIPT_DIR=""
HUGO_DIR=""
RESOLVED_HUGO_DIR=""
LOCAL_PREVIEW_URL="http://localhost:1313/"
PUBLISH_BASE_URL="https://jobsdocs.ccwu.cc/"
CI_MODE="false"

# ✅ 日志输出函数
log()            { echo -e "$1" | jobs_prompt_tee "$LOG_FILE"; }
color_echo()     { log "\033[1;32m$1\033[0m"; }         # ✅ 正常绿色输出
info_echo()      { log "\033[1;34mℹ $1\033[0m"; }       # ℹ 信息
success_echo()   { log "\033[1;32m✔ $1\033[0m"; }       # ✔ 成功
warn_echo()      { log "\033[1;33m⚠ $1\033[0m"; }       # ⚠ 警告
warm_echo()      { log "\033[1;33m$1\033[0m"; }         # 🟡 温馨提示（无图标）
note_echo()      { log "\033[1;35m➤ $1\033[0m"; }       # ➤ 说明
error_echo()     { log "\033[1;31m✖ $1\033[0m"; }       # ✖ 错误
err_echo()       { log "\033[1;31m$1\033[0m"; }         # 🔴 错误纯文本
debug_echo()     { log "\033[1;35m🐞 $1\033[0m"; }      # 🐞 调试
highlight_echo() { log "\033[1;36m🔹 $1\033[0m"; }      # 🔹 高亮
gray_echo()      { log "\033[0;90m$1\033[0m"; }         # ⚫ 次要信息
bold_echo()      { log "\033[1m$1\033[0m"; }            # 📝 加粗
underline_echo() { log "\033[4m$1\033[0m"; }            # 🔗 下划线

# 获取脚本真实所在目录。
get_script_dir() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
}

# 判断指定目录是否是 Hugo 站点目录。
is_hugo_dir() {
    local dir="$1"

    [[ -d "$dir" && -f "$dir/hugo.toml" ]]
}

# 判断指定目录是否存在同步脚本 sync_docs.sh。
has_sync_script() {
    local dir="$1"

    [[ -f "$dir/sync_docs.sh" ]]
}

# 清理用户拖入路径里的引号、file:// 前缀、转义空格和尾部斜杠。
normalize_input_path() {
    local input="$1"

    input="$(printf '%s' "$input" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    input="${input#file://}"
    input="${input%/}"

    if [[ "$input" == \"*\" && "$input" == *\" ]]; then
        input="${input:1:${#input}-2}"
    fi

    if [[ "$input" == \'*\' && "$input" == *\' ]]; then
        input="${input:1:${#input}-2}"
    fi

    input="$(printf '%s' "$input" \
        | sed 's/\\ / /g' \
        | sed 's/\\(/(/g' \
        | sed 's/\\)/)/g' \
        | sed 's/\\&/\&/g' \
        | sed 's/\\\[/[/g' \
        | sed 's/\\\]/]/g')"

    printf '%s' "$input"
}

# 根据用户输入或拖入内容解析 Hugo 目录，并写入 RESOLVED_HUGO_DIR。
resolve_hugo_dir_from_input() {
    local input="$1"
    local path

    RESOLVED_HUGO_DIR=""

    path="$(normalize_input_path "$input")"

    if [[ -f "$path" && "$(basename "$path")" == "hugo.toml" ]]; then
        RESOLVED_HUGO_DIR="$(dirname "$path")"
        return 0
    fi

    if is_hugo_dir "$path"; then
        RESOLVED_HUGO_DIR="$path"
        return 0
    fi

    return 1
}

# 解析终端预览或 CI 一次性构建模式。
parse_execution_mode() {
    if [[ "$#" -gt 1 ]]; then
        error_echo "仅支持一个可选参数：--ci"
        exit 1
    fi

    case "${1:-}" in
        "")
            CI_MODE="false"
            ;;
        --ci)
            CI_MODE="true"
            ;;
        *)
            error_echo "未知参数：$1；仅支持 --ci"
            exit 1
            ;;
    esac

    if [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
        CI_MODE="true"
    fi
}
# 自述信息：脚本启动后先展示用途、产物和注意事项。
print_banner() {
    highlight_echo "═════════════════════════════════════════════════════════════════════" | jobs_intro_style title
    if [[ "$CI_MODE" == "true" ]]; then
        highlight_echo "🚀 Hugo 博客生成器 - JobsDocs CI 同步与正式构建" | jobs_intro_style title
    else
        highlight_echo "🚀 Hugo 博客本地预览启动器 - JobsDocs Markdown 同步与预览" | jobs_intro_style title
    fi
    highlight_echo "═════════════════════════════════════════════════════════════════════" | jobs_intro_style title
}

# 打印脚本内置自述，并按运行模式决定是否等待回车。
show_script_intro_and_wait() {
    : > "$LOG_FILE"
    parse_execution_mode "$@"
    print_banner
    note_echo "功能说明：" | jobs_intro_style title
    color_echo "1. 脚本会优先检测当前脚本所在目录是否存在 hugo.toml。" | jobs_intro_style body
    color_echo "2. 如果脚本放在 JobsDocs 根目录，也会自动检测 ./blog/hugo.toml。" | jobs_intro_style body
    color_echo "3. 如果自动检测不到，会循环让你输入或拖入 Hugo 目录，直到找到 hugo.toml。" | jobs_intro_style body
    color_echo "4. 找到 Hugo 目录后，会自动执行 chmod +x sync_docs.sh。" | jobs_intro_style body
    color_echo "5. 然后执行 ./sync_docs.sh，把 JobsDocs Markdown 同步到 Hugo content/posts。" | jobs_intro_style body
    if [[ "$CI_MODE" == "true" ]]; then
        color_echo "6. CI 模式会执行一次 hugo --gc --minify，生成 blog/public 后退出。" | jobs_intro_style body
        color_echo "7. CI 模式不等待输入、不启动常驻服务，也不打开浏览器。" | jobs_intro_style body
    else
        color_echo "6. 最后执行 hugo server -D --disableFastRender，启动本地预览。" | jobs_intro_style body
        color_echo "7. Hugo 服务启动后，会自动打开浏览器访问 ${LOCAL_PREVIEW_URL}。" | jobs_intro_style body
    fi
    warm_echo "" | jobs_intro_style body
    warm_echo "要求：目标 Hugo 目录里必须存在 hugo.toml 和 sync_docs.sh。" | jobs_intro_style body
    if [[ "$CI_MODE" == "true" ]]; then
        warm_echo "正式站点地址：${PUBLISH_BASE_URL}" | jobs_intro_style body
    else
        warm_echo "本地预览地址：${LOCAL_PREVIEW_URL}" | jobs_intro_style body
    fi
    info_echo "日志文件：$LOG_FILE" | jobs_intro_style body
    warm_echo "" | jobs_intro_style body

    if [[ "$CI_MODE" == "true" ]]; then
        gray_echo "已进入 CI 无交互模式，开始生成博客文件。" | jobs_intro_style body
        return 0
    fi

    bold_echo "准备好后按 Enter 继续..." | jobs_intro_style body | jobs_prompt_filter
    IFS= read -r _
}

# 自动检测 Hugo 站点目录，并写入全局变量 HUGO_DIR。
detect_hugo_dir() {
    HUGO_DIR=""

    if is_hugo_dir "$SCRIPT_DIR"; then
        HUGO_DIR="$SCRIPT_DIR"
        success_echo "已自动识别 Hugo 目录：$HUGO_DIR"
        return 0
    fi

    if is_hugo_dir "$SCRIPT_DIR/blog"; then
        HUGO_DIR="$SCRIPT_DIR/blog"
        success_echo "已自动识别 Hugo 目录：$HUGO_DIR"
        return 0
    fi

    return 1
}

# 循环让用户输入或拖入 Hugo 目录，直到检测到 hugo.toml。
ask_hugo_dir_until_valid() {
    local input

    while true; do
        warm_echo ""
        note_echo "请输入或拖入 Hugo 站点目录，也可以直接拖入 hugo.toml 文件："
        IFS= read -r input

        if [[ -z "${input// }" ]]; then
            warn_echo "输入为空，请重新输入。"
            continue
        fi

        if resolve_hugo_dir_from_input "$input"; then
            HUGO_DIR="$RESOLVED_HUGO_DIR"
            success_echo "已识别 Hugo 目录：$HUGO_DIR"
            return 0
        fi

        error_echo "没有找到 hugo.toml，请确认你拖入的是 Hugo 站点目录或 hugo.toml 文件。"
    done
}

# 获取最终可用的 Hugo 站点目录。
get_hugo_dir() {
    if detect_hugo_dir; then
        return 0
    fi

    warn_echo "脚本所在目录和 ./blog 目录都没有检测到 hugo.toml。"
    ask_hugo_dir_until_valid
}

# 检查 Hugo 命令是否存在。
check_hugo_command() {
    if ! command -v hugo >/dev/null 2>&1; then
        error_echo "未检测到 hugo 命令。"
        warm_echo "请先安装 Hugo，例如：brew install hugo"
        exit 1
    fi
}

# 检查 curl 命令是否存在，用于判断 Hugo 本地服务是否启动。
check_curl_command() {
    if ! command -v curl >/dev/null 2>&1; then
        error_echo "未检测到 curl 命令，无法自动检测 Hugo 服务是否启动。"
        warm_echo "macOS 正常情况下自带 curl，请检查系统环境。"
        exit 1
    fi
}

# 检查 open 命令是否存在，用于打开默认浏览器。
check_open_command() {
    if ! command -v open >/dev/null 2>&1; then
        error_echo "未检测到 open 命令，无法自动打开浏览器。"
        exit 1
    fi
}

# 检查 Hugo 目录里的必要文件。
check_hugo_project_files() {
    if ! is_hugo_dir "$HUGO_DIR"; then
        error_echo "目标目录不是 Hugo 站点目录：$HUGO_DIR"
        exit 1
    fi

    if ! has_sync_script "$HUGO_DIR"; then
        error_echo "目标目录里没有 sync_docs.sh：$HUGO_DIR/sync_docs.sh"
        warm_echo "请先把同步脚本放到 Hugo 目录下。"
        exit 1
    fi
}

# 执行 Markdown 同步脚本。
run_sync_docs() {
    local root_dir

    info_echo "进入 Hugo 目录：$HUGO_DIR"
    cd "$HUGO_DIR"
    root_dir="$(cd "$HUGO_DIR/.." && pwd)"

    info_echo "赋予 sync_docs.sh 可执行权限。"
    chmod +x sync_docs.sh

    info_echo "开始同步 JobsDocs Markdown 文档。"
    BLOG_DIR="$HUGO_DIR" ROOT_DIR="$root_dir" ./sync_docs.sh

    success_echo "Markdown 同步完成。"
}

# 等待 Hugo 服务启动成功后，自动打开浏览器。
open_local_preview_when_ready() {
    local url="$1"

    (
        for _ in {1..60}; do
            if curl -fsS "$url" >/dev/null 2>&1; then
                success_echo "Hugo 服务已启动，正在打开浏览器：$url"
                open "$url" >/dev/null 2>&1 || true
                exit 0
            fi

            sleep 1
        done

        warn_echo "等待 Hugo 服务启动超时，仍然尝试打开浏览器：$url"
        open "$url" >/dev/null 2>&1 || true
    ) &
}

# 启动 Hugo 本地预览服务，并自动打开浏览器。
run_hugo_server() {
    cd "$HUGO_DIR"

    info_echo "启动 Hugo 本地预览服务。"
    warm_echo "访问地址：${LOCAL_PREVIEW_URL}"
    warm_echo "停止服务：在终端按 Control + C"
    warm_echo ""

    open_local_preview_when_ready "$LOCAL_PREVIEW_URL"

    hugo server -D --disableFastRender
}

# 执行 CI 一次性正式构建并生成 public 目录。
run_hugo_build() {
    cd "$HUGO_DIR"
    info_echo "开始执行 Hugo 正式构建。"
    hugo --gc --minify --baseURL "$PUBLISH_BASE_URL"
    success_echo "Hugo 正式构建完成：$HUGO_DIR/public"
}
# 初始化脚本目录和当前工作目录。
initialize_runtime() {
    get_script_dir
    cd "$SCRIPT_DIR"
    info_echo "脚本所在目录：$SCRIPT_DIR"
}
# 获取并检查最终使用的 Hugo 项目目录。
prepare_hugo_project() {
    get_hugo_dir
    check_hugo_command
    check_hugo_project_files
}
# 仅在本地预览模式检查浏览器联动依赖。
check_preview_environment() {
    if [[ "$CI_MODE" == "true" ]]; then
        return 0
    fi

    check_curl_command
    check_open_command
}
# 按运行模式启动本地预览或执行一次正式构建。
run_selected_hugo_mode() {
    if [[ "$CI_MODE" == "true" ]]; then
        run_hugo_build
        return 0
    fi

    run_hugo_server
}
# 编排脚本自述、文档同步和 Hugo 输出流程。
main() {
    show_script_intro_and_wait "$@" # 打印内置自述，并在终端预览模式等待用户确认。
    initialize_runtime # 定位脚本与 Hugo 站点所在目录，统一后续相对路径。
    prepare_hugo_project # 检查 Hugo 命令、配置文件和文档同步入口。
    check_preview_environment # 只为本地浏览器预览检查 curl 和 open 命令。
    run_sync_docs # 按本地与 CI 共用规则重新生成 Hugo 内容目录。
    run_selected_hugo_mode # 本地启动预览服务，CI 完成一次正式构建后退出。
}

main "$@"
