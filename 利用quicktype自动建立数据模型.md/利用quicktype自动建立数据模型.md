# 利用[**quicktype**](https://github.com/glideapps/quicktype)自动建立数据模型

> [**quicktype@网页端**](https://app.quicktype.io/)

[toc]

## 一、安装

> ```shell
> quicktype --version # 验证安装
> ```

### 1、手动安装

* 利用[**npm**](https://www.npmjs.com/)安装

  ```shell
  brew install node
  
  npm install -g quicktype
  ```

* 利用[**Homebrew**](https://brew.sh/)安装

  ```shell
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  brew install quicktype
  ```

### 2、脚本安装

```shell
#!/usr/bin/env bash

# ================================== 日志与输出函数 ==================================
SCRIPT_BASENAME=$(basename "$0" | sed 's/\.[^.]*$//')   # 当前脚本名（去掉扩展名）
LOG_FILE="/tmp/${SCRIPT_BASENAME}.log"                  # 设置对应的日志文件路径

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

# ================================== 写入 Homebrew shellenv ==================================
inject_shellenv_block() {
    local profile_file="$1"   # 比如 ~/.zprofile
    local shellenv="$2"       # 比如 eval "$(/opt/homebrew/bin/brew shellenv)"
    local header="# >>> brew shellenv (auto) >>>"

    if [[ -z "$profile_file" || -z "$shellenv" ]]; then
        error_echo "❌ 缺少参数：inject_shellenv_block <profile_file> <shellenv>"
        return 1
    fi

    touch "$profile_file" 2>/dev/null || {
        error_echo "❌ 无法写入配置文件：$profile_file"
        return 1
    }

    if grep -Fq "$shellenv" "$profile_file" 2>/dev/null; then
        info_echo "📌 配置文件中已存在 brew shellenv：$profile_file"
    else
        {
            echo ""
            echo "$header"
            echo "$shellenv"
        } >> "$profile_file"
        success_echo "✅ 已写入 brew shellenv 到：$profile_file"
    fi

    eval "$shellenv"
    success_echo "🟢 Homebrew 环境已在当前终端生效"
}

# ================================== 判断芯片架构（ARM64 / x86_64） ==================================
get_cpu_arch() {
    [[ $(uname -m) == "arm64" ]] && echo "arm64" || echo "x86_64"
}

# ================================== 自检安装 Homebrew（原逻辑） ==================================
install_homebrew() {
    local arch="$(get_cpu_arch)"            # 获取当前架构（arm64 或 x86_64）
    local shell_path="${SHELL##*/}"         # 获取当前 shell 名称（如 zsh、bash）
    local profile_file=""
    local brew_bin=""
    local shellenv_cmd=""

    if ! command -v brew &>/dev/null; then
        warn_echo "🧩 未检测到 Homebrew，正在安装中...（架构：$arch）"

        if [[ "$arch" == "arm64" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
                error_echo "❌ Homebrew 安装失败（arm64）"
                exit 1
            }
            brew_bin="/opt/homebrew/bin/brew"
        else
            arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
                error_echo "❌ Homebrew 安装失败（x86_64）"
                exit 1
            }
            brew_bin="/usr/local/bin/brew"
        fi

        success_echo "✅ Homebrew 安装成功"

        # ==== 注入 shellenv 到对应配置文件（自动生效） ====
        shellenv_cmd="eval \"\$(${brew_bin} shellenv)\""

        case "$shell_path" in
            zsh)   profile_file="$HOME/.zprofile" ;;
            bash)  profile_file="$HOME/.bash_profile" ;;
            *)     profile_file="$HOME/.profile" ;;
        esac

        inject_shellenv_block "$profile_file" "$shellenv_cmd"
    else
        info_echo "🔄 Homebrew 已安装，简单检查中..."
        brew -v || warn_echo "⚠️ brew -v 执行异常，稍后可自行排查"
    fi
}

# ================================== 自检安装 fzf（原逻辑） ==================================
install_fzf() {
    if ! command -v fzf &>/dev/null; then
        warn_echo "🧩 未检测到 fzf，正在通过 Homebrew 安装..."
        brew install fzf || {
            error_echo "❌ fzf 安装失败，请手动检查 Homebrew"
            return 1
        }
        success_echo "✅ fzf 安装完成"
    else
        info_echo "✅ fzf 已安装"
    fi
}

# ================================== 自述说明 ==================================
print_readme() {
    bold_echo "🚀 Quicktype 自动安装 / 升级脚本"
    echo
    note_echo "本脚本将执行以下操作："
    gray_echo "  1) 检查并安装 / 更新 Homebrew"
    gray_echo "  2) 使用 Homebrew 检查并安装 / 升级 Node.js + npm"
    gray_echo "  3) 使用 Homebrew 检查并安装 / 升级 fzf"
    gray_echo "  4) 使用 npm 全局安装 / 升级 quicktype"
    gray_echo "  5) 完成后打印 quicktype 版本号"
    echo
    warm_echo "⚠ 过程中可能会请求 sudo 密码（用于 npm 全局安装 / 升级 quicktype）"
    echo
    read -r -p "👉 按回车继续执行，或 Ctrl + C 取消..." _
}

# ================================== Homebrew 安装 & 升级封装 ==================================
ensure_homebrew_and_upgrade() {
    install_homebrew

    if ! command -v brew &>/dev/null; then
        error_echo "❌ 未检测到 Homebrew，后续步骤无法继续"
        exit 1
    fi

    info_echo "🔄 正在更新 Homebrew 仓库..."
    brew update || warn_echo "⚠ Homebrew 更新失败，可稍后手动执行：brew update"

    info_echo "⬆ 正在升级已安装的 Homebrew 包（可能耗时较长）..."
    brew upgrade || warn_echo "⚠ Homebrew 升级过程中有错误，可稍后手动执行：brew upgrade"
}

# ================================== Node.js & npm 管理 ==================================
ensure_node_and_npm() {
    if brew list --versions node &>/dev/null; then
        info_echo "✅ 检测到通过 Homebrew 安装的 Node.js，尝试升级..."
        brew upgrade node || warn_echo "⚠ Node.js 升级失败，可稍后手动执行：brew upgrade node"
    else
        warn_echo "🧩 未检测到 Homebrew 管理的 Node.js，正在通过 Homebrew 安装 node（包含 npm）..."
        brew install node || {
            error_echo "❌ Node.js 安装失败，请检查 Homebrew 或网络"
            exit 1
        }
        success_echo "✅ Node.js 安装完成"
    fi

    info_echo "🔹 当前 Node.js 版本：$(node -v 2>/dev/null || echo '未检测到')"
    info_echo "🔹 当前 npm 版本：$(npm -v 2>/dev/null || echo '未检测到')"
}

# ================================== fzf 安装 & 升级封装 ==================================
ensure_fzf_with_upgrade() {
    if brew list --versions fzf &>/dev/null; then
        info_echo "✅ 检测到通过 Homebrew 安装的 fzf，尝试升级..."
        brew upgrade fzf || warn_echo "⚠ fzf 升级失败，可稍后手动执行：brew upgrade fzf"
    else
        install_fzf
    fi
}

# ================================== quicktype 安装 & 升级 ==================================
ensure_quicktype() {
    if ! command -v npm &>/dev/null; then
        error_echo "❌ 未检测到 npm，无法安装 quicktype，请先确保 Node.js 环境正常"
        exit 1
    fi

    if npm list -g quicktype --depth=0 >/dev/null 2>&1; then
        info_echo "✅ 检测到全局 quicktype，正在通过 npm 升级..."
        sudo npm update -g quicktype || {
            error_echo "❌ quicktype 升级失败，你可以稍后手动执行：sudo npm update -g quicktype"
            return 1
        }
        success_echo "✅ quicktype 已升级到最新版本"
    else
        warn_echo "🧩 未检测到全局 quicktype，正在通过 npm 安装..."
        sudo npm install -g quicktype || {
            error_echo "❌ quicktype 安装失败，你可以稍后手动执行：sudo npm install -g quicktype"
            return 1
        }
        success_echo "✅ quicktype 安装完成"
    fi
}

# ================================== 打印 quicktype 版本 ==================================
show_quicktype_version() {
    if command -v quicktype &>/dev/null; then
        local ver
        ver="$(quicktype --version 2>&1)"
        highlight_echo "🔹 当前 quicktype 版本：${ver}"
    else
        error_echo "❌ 未能检测到 quicktype 命令，请检查 npm 全局路径或重新安装"
    fi
}

# ================================== main 入口 ==================================
main() {
    print_readme
    ensure_homebrew_and_upgrade
    ensure_node_and_npm
    ensure_fzf_with_upgrade
    ensure_quicktype
    show_quicktype_version
    success_echo "🎉 Quicktype 自动安装 / 升级流程已结束"
}

main "$@"
```

## 二、在`.zshrc`里面配置全局函数

```shell
# ================================== 内部工具：选择 JSON 文件 ==================================
_qt_select_json() {
  local files file raw

  # 如果传了参数就优先用参数（虽然目前 qt 不传，但保留以防以后复用）
  if [[ -n "$1" ]]; then
    local candidate="$1"
    # 展开 ~ 等（zsh 特性）
    candidate=${~candidate}
    if [[ -f "$candidate" ]]; then
      REPLY="$candidate"
      return 0
    else
      echo "⚠️ 找不到文件: $candidate" >&2
      # 不直接 return，继续走自动扫描 + 手动输入流程
    fi
  fi

  # 递归查找当前目录下的 *.json
  raw=$(find . -type f -name '*.json' -print 2>/dev/null)

  if [[ -n "$raw" ]]; then
    # 找到了至少一个
    local -a files
    files=("${(@f)${raw}}")

    if (( ${#files[@]} == 1 )); then
      # ✅ 只有一个 JSON，直接用，不要动 fzf
      file="${files[1]}"
    else
      # 多于 1 个，才有必要用 fzf 选
      if command -v fzf >/dev/null 2>&1; then
        file=$(printf '%s\n' "${files[@]}" | fzf \
          --prompt="选择 JSON 文件> " \
          --header="扫描到 ${#files[@]} 个 JSON 文件，↑↓ 选择，回车确认")
        [[ -z "$file" ]] && return 1
      else
        # 没有 fzf，又不止一个文件，只能报错+列表
        echo "❌ 找到多个 JSON 文件，但未安装 fzf，无法交互选择" >&2
        printf '%s\n' "${files[@]}"
        return 1
      fi
    fi

    REPLY="$file"
    return 0
  fi

  # 走到这里说明：当前目录及子目录里一个 *.json 都没找到
  # 改为循环询问用户手动输入路径，直到正确或退出
  while true; do
    echo -n "❓ 未找到任何 *.json，请手动输入 JSON 文件路径（或输入 q 退出）："
    local input
    read -r input

    # 直接回车就继续问
    if [[ -z "$input" ]]; then
      continue
    fi

    # 用户主动退出
    if [[ "$input" == "q" || "$input" == "Q" ]]; then
      echo "🚪 已取消"
      return 1
    fi

    # 展开 ~ 等
    input=${~input}

    if [[ -f "$input" ]]; then
      REPLY="$input"
      return 0
    else
      echo "❌ 仍然找不到文件: $input" >&2
    fi
  done
}

# ================================== 公共：检查 quicktype ==================================
_qt_require_quicktype() {
  if ! command -v quicktype >/dev/null 2>&1; then
    echo "❌ 未找到 quicktype 命令，请先安装：npm i -g quicktype" >&2
    return 1
  fi
}

# ================================== 主命令：qt（Swift / Dart） ==================================
# 用法：
#   qt          # 交互选择语言（swift/dart）+ 自动扫描 json（1 个直用、多于 1 个用 fzf）
#   qt swift    # 固定 swift，自动扫描 json
#   qt dart     # 固定 dart，自动扫描 json
qt() {
  local lang

  # 1️⃣ 解析语言参数 / 交互式选择
  if [[ -z "$1" ]]; then
    # 没有参数：用 fzf 或菜单 选择语言
    if command -v fzf >/dev/null 2>&1; then
      lang=$(printf '%s\n' swift dart | fzf \
        --prompt="选择输出语言> " \
        --header="quicktype 目标语言（ESC 取消）")
      if [[ -z "$lang" ]]; then
        echo "🚪 已取消"
        return 1
      fi
    else
      # 无 fzf：用简单菜单
      while true; do
        echo "请选择输出语言："
        echo "  1) swift"
        echo "  2) dart"
        printf "输入序号或名称（默认 1 / swift，输入 q 退出）："
        local ans
        read -r ans
        case "$ans" in
          ""|1|swift|Swift|SWIFT)
            lang="swift"
            break
            ;;
          2|dart|Dart|DART)
            lang="dart"
            break
            ;;
          q|Q)
            echo "🚪 已取消"
            return 1
            ;;
          *)
            echo "❌ 无效输入，请重试"
            ;;
        esac
      done
    fi
  else
    # 有参数：只接受 swift / dart，其他一律报错
    case "$1" in
      swift|Swift|SWIFT)
        lang="swift"
        ;;
      dart|Dart|DART)
        lang="dart"
        ;;
      *)
        echo "❌ 不支持的参数: $1（只支持：swift / dart）" >&2
        return 1
        ;;
    esac
    shift
  fi

  # 现在只允许 0 个额外参数，彻底砍掉 “qt path/to/a.json” 这种用法
  if [[ -n "$1" ]]; then
    echo "❌ 不支持的额外参数: $*（现在只支持：qt / qt swift / qt dart）" >&2
    return 1
  fi

  # 2️⃣ 检查 quicktype 是否存在
  _qt_require_quicktype || return 1

  # 3️⃣ 选择 JSON 文件（自动扫描：1 个直用，多于 1 个 fzf；没有则手动输入）
  local json_file
  if ! _qt_select_json; then
    return 1
  fi
  json_file="$REPLY"

  # 4️⃣ 计算输出文件名：和 JSON 同目录、同主名，不同后缀
  local dir base ext out_file
  dir="${json_file:h}"
  base="${json_file:t:r}"

  case "$lang" in
    swift) ext="swift" ;;
    dart)  ext="dart"  ;;
    *)
      echo "❌ 理论上不会到这里：未知语言 $lang" >&2
      return 1
      ;;
  esac

  out_file="${dir}/${base}.${ext}"

  echo "📝 JSON:   $json_file"
  echo "💡 语言:   $lang"
  echo "🎯 输出:   $out_file"

  # 5️⃣ 组装 quicktype 命令
  local -a cmd
  cmd=(quicktype "$json_file" --lang "$lang" -o "$out_file")

  case "$lang" in
    swift)
      # Swift：关掉 init & CodingKeys，生成更干净的模型
      cmd+=(--no-initializers --no-coding-keys)
      ;;
    dart)
      # Dart 先默认；后面你要接 json_serializable / freezed 再调参数
      ;;
  esac

  echo "⚙️ 执行: ${cmd[*]}"
  "${cmd[@]}"
}
```

### 使用方式

* 路径定位于目标文件夹，使用如下命令
  * `qt`
  * `qt swift` 
  * `qt dart`

* 当目标文件夹中 有多个`*.json`文件时，会启用fzf，让用户选择当前场景所需要使用的`*.json`；如果只有一个`*.json`则不进行选择，直接进入
* 目前仅支持[**Swift**](https://www.swift.org/)和[**dart**](https://dart.dev/)