#!/usr/bin/env bash

# ==============================================================================
# Antigravity 2.0.1+ macOS 自动化汉化安装脚本
# ==============================================================================

set -euo pipefail

# 颜色控制字符
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}    Antigravity 2.0.1+ macOS 自动化汉化注入工具      ${NC}"
echo -e "${BLUE}=====================================================${NC}"

# 1. 确认是否是 macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}错误: 此脚本仅适用于 macOS。${NC}"
    exit 1
fi

# 2. 检查 Python 3
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}错误: 未检测到 python3。请先安装 Python 3 运行环境。${NC}"
    exit 1
fi

# 3. 检查 npx
if ! command -v npx &>/dev/null; then
    echo -e "${RED}错误: 未检测到 Node.js (npx)。请先安装 Node.js 运行环境。${NC}"
    exit 1
fi

# 4. 定位应用程序与文件路径
APP_PATH="/Applications/Antigravity.app"
ASAR_PATH="$APP_PATH/Contents/Resources/app.asar"
LOG_PATH="$HOME/Library/Logs/Antigravity/language_server.log"
APP_DATA_DIR="$HOME/Library/Application Support/Antigravity"
TMP_DIR=$(mktemp -d -t agy-zhcn-XXXXXX)

# 清理钩子
trap 'rm -rf "$TMP_DIR"' EXIT

if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}错误: 未在 /Applications 中找到 Antigravity.app。${NC}"
    echo -e "请确认您已成功安装 Antigravity 桌面版。"
    exit 1
fi

# 5. 读取运行中的端口以获取 original Bundle
echo -e "${YELLOW}[1/6] 正在检测运行中的 Antigravity 端口...${NC}"
if [ ! -f "$LOG_PATH" ]; then
    echo -e "${RED}错误: 未找到运行日志 ($LOG_PATH)。${NC}"
    echo -e "请确保您已经打开过至少一次 Antigravity 2.0.1。"
    exit 1
fi

# 从日志中提取最近一次的 HTTP 监听端口
PORT=$(grep -oE 'listening on random port at [0-9]+ for HTTP' "$LOG_PATH" | tail -n 1 | grep -oE '[0-9]+' || true)

if [ -z "$PORT" ]; then
    echo -e "${RED}错误: 无法在日志中检测到运行中的端口。${NC}"
    echo -e "请保持 Antigravity 软件在后台运行，然后重新执行此脚本。"
    exit 1
fi

echo -e "${GREEN}检测到活跃端口: $PORT${NC}"

# 6. 下载主 bundle (main.js)
echo -e "${YELLOW}[2/6] 正在拉取原厂前端资源包 (main.js)...${NC}"
if ! curl -s -o "$TMP_DIR/ui_main.js" "http://127.0.0.1:$PORT/main.js"; then
    echo -e "${RED}错误: 无法从 http://127.0.0.1:$PORT/main.js 下载资源。${NC}"
    echo -e "请确保 Antigravity 软件处于启动状态！"
    exit 1
fi

# 7. 运行 Python 脚本生成汉化包
echo -e "${YELLOW}[3/6] 正在运行汉化引擎生成中文 UI 资源...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export APPDATA="$HOME/Library/Application Support"

if ! python3 "$SCRIPT_DIR/translate_ui.py" --input "$TMP_DIR/ui_main.js"; then
    echo -e "${RED}错误: 汉化包生成失败。${NC}"
    exit 1
fi

# 8. 解包、注入补丁与重新封包 (原子操作)
echo -e "${YELLOW}[4/6] 正在提取与注入汉化补丁...${NC}"
npx -y @electron/asar@3.4.1 extract "$ASAR_PATH" "$TMP_DIR/extracted"

# 用 customScheme.ai-ui.js 覆盖 customScheme.js
cp "$SCRIPT_DIR/customScheme.ai-ui.js" "$TMP_DIR/extracted/dist/customScheme.js"

# 重新打包至临时新文件，确保写入原子性
echo -e "${YELLOW}[5/6] 正在生成新版 app.asar 封包并进行版本化备份...${NC}"
NEW_ASAR="$TMP_DIR/app.asar.new"
npx -y @electron/asar@3.4.1 pack "$TMP_DIR/extracted" "$NEW_ASAR"

# 验证打包结果是否正常
if [ ! -s "$NEW_ASAR" ]; then
    echo -e "${RED}错误: 新 app.asar 生成失败或为空文件，操作已中止以防止损坏软件。${NC}"
    exit 1
fi

# 计算原 app.asar 的哈希与当前时间戳，实现版本化历史备份
ORIGINAL_SHA=$(shasum -a 256 "$ASAR_PATH" | awk '{print $1}')
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_PATH="${ASAR_PATH}.bak.${ORIGINAL_SHA:0:12}.${TIMESTAMP}"

# 复制原版备份
cp "$ASAR_PATH" "$BACKUP_PATH"
echo -e "${GREEN}原版 app.asar 已成功版本化备份为: ${BACKUP_PATH}${NC}"

# 原子式移动替换原 app.asar 文件
mv "$NEW_ASAR" "$ASAR_PATH"

# 10. 完成
echo -e "${YELLOW}[6/6] 正在清理临时文件...${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}        🎉 Antigravity 2.0.1+ macOS 汉化注入成功！    ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "请按以下步骤启动软件以查看效果："
echo -e "1. 在 Mac 菜单栏中点击 ${YELLOW}Quit${NC}（或按 ${YELLOW}Cmd + Q${NC}）彻底退出软件。"
echo -e "2. 重新启动 ${GREEN}Antigravity${NC} 即可享受纯中文开发体验！"
echo -e "====================================================="
