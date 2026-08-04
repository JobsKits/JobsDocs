#!/usr/bin/env bash
# 脚本自述：
# - 脚本名称：install.command
# - 核心用途：同步 JobsDocs 文档，并按运行模式生成 Hugo 站点或启动本地预览。
# - 影响范围：会重新生成 blog/content、blog/public 及相关 Hugo 运行文件。
# - 运行提示：终端默认等待确认后预览；传入 --ci 时无交互完成一次正式构建后退出。
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
log()            { echo -e "$1" | tee -a "$LOG_FILE"; }
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
    highlight_echo "═════════════════════════════════════════════════════════════════════"
    if [[ "$CI_MODE" == "true" ]]; then
        highlight_echo "🚀 Hugo 博客生成器 - JobsDocs CI 同步与正式构建"
    else
        highlight_echo "🚀 Hugo 博客本地预览启动器 - JobsDocs Markdown 同步与预览"
    fi
    highlight_echo "═════════════════════════════════════════════════════════════════════"
}

# 打印脚本内置自述，并按运行模式决定是否等待回车。
show_script_intro_and_wait() {
    : > "$LOG_FILE"
    parse_execution_mode "$@"
    print_banner
    note_echo "功能说明："
    color_echo "1. 脚本会优先检测当前脚本所在目录是否存在 hugo.toml。"
    color_echo "2. 如果脚本放在 JobsDocs 根目录，也会自动检测 ./blog/hugo.toml。"
    color_echo "3. 如果自动检测不到，会循环让你输入或拖入 Hugo 目录，直到找到 hugo.toml。"
    color_echo "4. 找到 Hugo 目录后，会自动执行 chmod +x sync_docs.sh。"
    color_echo "5. 然后执行 ./sync_docs.sh，把 JobsDocs Markdown 同步到 Hugo content/posts。"
    if [[ "$CI_MODE" == "true" ]]; then
        color_echo "6. CI 模式会执行一次 hugo --gc --minify，生成 blog/public 后退出。"
        color_echo "7. CI 模式不等待输入、不启动常驻服务，也不打开浏览器。"
    else
        color_echo "6. 最后执行 hugo server -D --disableFastRender，启动本地预览。"
        color_echo "7. Hugo 服务启动后，会自动打开浏览器访问 ${LOCAL_PREVIEW_URL}。"
    fi
    warm_echo ""
    warm_echo "要求：目标 Hugo 目录里必须存在 hugo.toml 和 sync_docs.sh。"
    if [[ "$CI_MODE" == "true" ]]; then
        warm_echo "正式站点地址：${PUBLISH_BASE_URL}"
    else
        warm_echo "本地预览地址：${LOCAL_PREVIEW_URL}"
    fi
    info_echo "日志文件：$LOG_FILE"
    warm_echo ""

    if [[ "$CI_MODE" == "true" ]]; then
        gray_echo "已进入 CI 无交互模式，开始生成博客文件。"
        return 0
    fi

    bold_echo "准备好后按 Enter 继续..."
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
