# ==============================================================================
#    Antigravity 2.0.6+ Windows 自动化汉化注入脚本 (PowerShell)
# ==============================================================================
$ErrorActionPreference = "Stop"

Write-Host "=====================================================" -ForegroundColor Blue
Write-Host "    Antigravity 2.0.6+ Windows 自动化汉化注入工具     " -ForegroundColor Blue
Write-Host "=====================================================" -ForegroundColor Blue

# 1. 确认是否是 Windows
if ($PSVersionTable.OS -and $PSVersionTable.OS -notmatch "Windows") {
    Write-Error "错误: 此脚本仅适用于 Windows 系统。"
    exit 1
}

# 2. 检查 Python 3
try {
    $pythonVersion = python --version 2>&1
    Write-Host "检测到 Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Error "错误: 未检测到 python。请先安装 Python 3 运行环境，并确保将其添加到了系统 PATH 中。"
    exit 1
}

# 3. 检查 npx
try {
    $npxVersion = npx -v 2>&1
    Write-Host "检测到 Node.js (npx) 版本: $npxVersion" -ForegroundColor Green
} catch {
    Write-Error "错误: 未检测到 Node.js (npx)。请先安装 Node.js 运行环境。"
    exit 1
}

# 4. 定位应用程序与文件路径
$AppPath = "$env:LOCALAPPDATA\Programs\Antigravity"
if (-not (Test-Path $AppPath)) {
    # 尝试检查 C:\Program Files 全局安装路径
    $AppPath = "C:\Program Files\Antigravity"
}

$AsarPath = "$AppPath\resources\app.asar"
$LogPath = "$env:LOCALAPPDATA\Antigravity\logs\language_server.log"
$AppDataDir = "$env:APPDATA\Antigravity"

# 创建临时工作目录
$TmpDir = [System.IO.Path]::GetTempFileName()
Remove-Item $TmpDir
New-Item -ItemType Directory -Path $TmpDir | Out-Null

# 注册清理钩子，在脚本退出时清理临时目录
$cleanup = {
    if (Test-Path $TmpDir) {
        Remove-Item -Recururse -Force $TmpDir -ErrorAction SilentlyContinue
    }
}
Register-EngineEvent -SourceIdentifier "PowerShell.Exiting" -Action $cleanup | Out-Null

if (-not (Test-Path $AppPath) -or -not (Test-Path $AsarPath)) {
    Write-Host "错误: 未找到 Antigravity 桌面版安装路径 ($AppPath)。" -ForegroundColor Red
    Write-Host "请确认您已成功安装 Antigravity 2.0.6+ Windows 桌面版。"
    exit 1
}

# 5. 读取运行中的端口以获取 original Bundle
Write-Host "[1/6] 正在检测运行中的 Antigravity 端口..." -ForegroundColor Yellow
if (-not (Test-Path $LogPath)) {
    Write-Host "错误: 未找到运行日志 ($LogPath)。" -ForegroundColor Red
    Write-Host "请确保您已经打开过至少一次 Antigravity 软件。"
    exit 1
}

# 从日志中提取最近一次的 HTTP 监听端口
$logContent = Get-Content -Path $LogPath -Encoding UTF8 -Tail 200
$portMatch = $logContent | Select-String -Pattern "listening on random port at (\d+) for HTTP" | Select-Object -Last 1

if (-not $portMatch) {
    Write-Host "错误: 无法在日志中检测到运行中的端口。" -ForegroundColor Red
    Write-Host "请保持 Antigravity 软件在后台运行，然后重新执行此脚本。"
    exit 1
}

$Port = $portMatch.Matches.Groups[1].Value
Write-Host "检测到活跃端口: $Port" -ForegroundColor Green

# 6. 下载主 bundle (main.js)
Write-Host "[2/6] 正在拉取原厂前端资源包 (main.js)..." -ForegroundColor Yellow
$UiMainPath = Join-Path $TmpDir "ui_main.js"
try {
    Invoke-WebRequest -Uri "http://127.0.0.1:$Port/main.js" -OutFile $UiMainPath -UseBasicParsing
} catch {
    Write-Host "错误: 无法从 http://127.0.0.1:$Port/main.js 下载资源。" -ForegroundColor Red
    Write-Host "请确保 Antigravity 软件处于启动状态！"
    exit 1
}

# 7. 运行 Python 脚本生成汉化包
Write-Host "[3/6] 正在运行汉化引擎生成中文 UI 资源..." -ForegroundColor Yellow
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$TranslateScript = Join-Path $ScriptDir "translate_ui.py"

# 设置环境变量 APPDATA 并执行 Python 翻译脚本
$env:APPDATA = "$env:APPDATA"
& python $TranslateScript --input $UiMainPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 汉化包生成失败。" -ForegroundColor Red
    exit 1
}

# 8. 备份原始 asar 包
Write-Host "[4/6] 正在备份原厂 app.asar 包..." -ForegroundColor Yellow
$BackupPath = "$AsarPath.bak"
if (-not (Test-Path $BackupPath)) {
    Copy-Item -Path $AsarPath -Destination $BackupPath -Force
    Write-Host "备份成功: $BackupPath" -ForegroundColor Green
} else {
    Write-Host "原有备份已存在，跳过备份步骤。" -ForegroundColor Blue
}

# 9. 解包、打重定向补丁并重新封包
Write-Host "[5/6] 正在解包、注入补丁并封包 (此步骤需要几秒钟)..." -ForegroundColor Yellow
$ExtractedDir = Join-Path $TmpDir "extracted"

# 临时提取 asar
& npx -y @electron/asar extract $AsarPath $ExtractedDir

# 用 customScheme.ai-ui.js 覆盖 customScheme.js
$CustomSchemeSource = Join-Path $ScriptDir "customScheme.ai-ui.js"
$CustomSchemeDest = Join-Path $ExtractedDir "dist\customScheme.js"
Copy-Item -Path $CustomSchemeSource -Destination $CustomSchemeDest -Force

# 重新封包写回系统
& npx -y @electron/asar pack $ExtractedDir $AsarPath

# 10. 完成
Write-Host "[6/6] 正在清理临时文件..." -ForegroundColor Yellow
& $cleanup

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "        🎉 Antigravity Windows 汉化注入成功！        " -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "请按以下步骤启动软件以查看效果："
Write-Host "1. 在任务栏或系统托盘中彻底退出 Antigravity 软件。"
Write-Host "2. 重新启动 Antigravity 即可享受纯中文开发体验！"
Write-Host "====================================================="
