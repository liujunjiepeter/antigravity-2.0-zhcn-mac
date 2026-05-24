# Antigravity 2.0+ 自动化汉化注入工具 (macOS & Windows 双平台版)

本仓库提供对 AI 辅助开发工具 **Antigravity 2.0.1+** 客户端界面的**一键全自动化中文本地化（汉化）支持**，完美适配 macOS 与 Windows 双平台。

由于 Antigravity 2.0.1+ 版本的分发结构改变（去除了原有的 `out` 目录散件，全面改用加密封包 `app.asar` 格式），且每次运行后本地 Language Server 的 HTTP 端口完全随机，原本传统的静态文件替换方法均已失效。

本套件通过自动化扫描日志获取动态端口、拉取本地未混淆原厂 UI 资源、调用汉化翻译引擎生成中文资源、动态解包/打补丁/重打包 `app.asar`，实现了一键式、无损且安全的双平台汉化注入。

---

## 🌟 项目亮点

- **双平台完美支持**：针对 macOS 和 Windows 提供原生一键式脚本（Bash / PowerShell / Batch）。
- **全自动化极速体验**：一键运行，全自动完成端口检测、资源获取、汉化包生成、ASAR 解包、补丁注入与重新打包。
- **智能日志端口扫描**：自动解析 Language Server 运行日志，提取最近一次活跃端口，彻底解决动态随机端口难题。
- **无损且安全 (自动备份)**：在对系统级 `app.asar` 进行任何修改前，会自动在同目录下创建 `app.asar.bak` 备份文件。如遇问题，随时可以一键恢复。
- **卓越的适配性**：完美兼容 **Antigravity v2.0.1 - v2.0.6+** 桌面客户端。

---

## 🛠️ 环境要求

在运行脚本前，请确保您的电脑满足以下条件：

### 🍎 macOS 平台
1. **操作系统**：macOS (Intel/Apple Silicon 均可)
2. **已安装 Antigravity.app** 并确保其位于 `/Applications/Antigravity.app`。
3. **Python 3**：可在终端运行 `python3 --version` 验证。
4. **Node.js (含 npx)**：可在终端运行 `npx -v` 验证。

### 💻 Windows 平台
1. **操作系统**：Windows 10 / 11 
2. **已安装 Antigravity 桌面版**（安装于默认路径 `%LOCALAPPDATA%\Programs\Antigravity` 或 `C:\Program Files\Antigravity`）。
3. **Python 3**：可在命令行运行 `python --version` 验证，并确保已加入系统环境变量 PATH 中。
4. **Node.js (含 npx)**：可在命令行运行 `npx -v` 验证。

---

## 🚀 汉化步骤

> [!IMPORTANT]
> **请务必在运行脚本前确保 Antigravity 正在后台运行**（如果是首次安装，请至少启动过一次软件），因为汉化引擎需要从软件的本地活跃端口下载最原始的、未压缩的 `main.js` 前端核心代码进行精确翻译。

### 1. 克隆/下载本仓库到本地

```bash
git clone https://github.com/liujunjiepeter/antigravity-2.0-zhcn-mac.git
cd antigravity-2.0-zhcn-mac
```

### 2. 运行一键汉化脚本

#### 🍎 macOS 平台
打开终端并运行：
```bash
chmod +x install_mac.sh
./install_mac.sh
```

#### 💻 Windows 平台
双击运行 `install_windows.bat` 文件，或者在 PowerShell 中以管理员/常规身份运行：
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\install_windows.ps1
```

### 3. 重启软件生效

汉化完成后，请按照以下步骤重新启动软件：
1. **彻底退出软件**：
   - macOS：在 Mac 屏幕左上角菜单栏中点击 **Quit Antigravity**（或使用快捷键 `Cmd + Q`）彻底退出。
   - Windows：在系统托盘右下角找到 Antigravity 图标右键退出（或使用快捷键 `Cmd + Q` / `Ctrl + Q` 彻底退出）。
2. **重新打开** Antigravity，即可尽情享受纯中文的开发体验！🎉

---

## 🔄 卸载或还原

如果您需要恢复为纯英版原厂界面，只需恢复备份的 `.bak` 文件并删除汉化缓存即可：

#### 🍎 macOS 平台
```bash
cp /Applications/Antigravity.app/Contents/Resources/app.asar.bak /Applications/Antigravity.app/Contents/Resources/app.asar
rm -f ~/Library/Application\ Support/Antigravity/zh_cn_ui_main.js
```

#### 💻 Windows 平台
在 PowerShell 中运行：
```powershell
$AppPath = "$env:LOCALAPPDATA\Programs\Antigravity" # 若是全局安装请使用 "C:\Program Files\Antigravity"
Copy-Item -Path "$AppPath\resources\app.asar.bak" -Destination "$AppPath\resources\app.asar" -Force
Remove-Item -Path "$env:APPDATA\Antigravity\zh_cn_ui_main.js" -Force
```

---

## 📂 仓库结构

- `install_mac.sh` - macOS 一键式全自动化汉化注入脚本。
- `install_windows.ps1` / `install_windows.bat` - Windows 一键式全自动化汉化注入脚本与引导批处理。
- `translate_ui.py` - 核心汉化逻辑与文本映射引擎。
- `customScheme.ai-ui.js` - 自定义协议拦截补丁（用于拦截 `main.js` 请求并智能重定向至我们生成的中文 `zh_cn_ui_main.js`）。

---

## 🤝 鸣谢与声明

- 本项目的核心汉化字典与 Python 翻译引擎基础来自于 Windows 汉化开源项目 [antigravity-2.0-zhcn](https://github.com/kakarotto-baroko/antigravity-2.0-zhcn)。
- 本项目针对 macOS / Windows 平台做了全面的架构重构、ASAR 解包封包适配、以及全自动化脚本支持。

---

## 📄 开源许可证 (License)

本项目采用 **GPL 3.0** 开源许可证：
- **免费使用**：任何人均可免费下载、使用、分发和修改本项目代码。
- **强制开源**：任何基于本项目的衍生作品、修改版本或二次发布版本，**必须同样以 GPL 3.0 协议公开源代码**。
