# Antigravity 2.0 macOS 汉化注入工具 (macOS 专版)

本仓库专为 macOS 用户设计，提供对 AI 辅助物理仿真/开发工具 **Antigravity 2.0.1+** 客户端界面的**一键全自动化中文本地化（汉化）支持**。

由于 Antigravity 2.0.1+ 在 macOS 上的分发结构改变（去除了原有的 `resources/app/out` 散件，全面改用加密封包 `app.asar` 格式），且每次运行后本地 Language Server 的 HTTP 端口完全随机，原本的 Windows 汉化覆盖方法或静态文件替换在 Mac 上均已失效。

本套件通过自动化扫描日志获取端口、拉取本地未混淆原厂 UI 资源、调用汉化翻译引擎生成中文资源、动态解包/打补丁/重打包 `app.asar`，实现了一键式、无损且安全的 macOS 汉化注入。

---

## 🌟 项目亮点

- **全自动化极速体验**：一键运行，全自动完成端口检测、资源获取、汉化包生成、ASAR 解包、补丁注入与重新打包。
- **智能日志端口扫描**：自动解析 `~/Library/Logs/Antigravity/language_server.log`，提取最近一次运行的活跃端口，彻底解决动态随机端口难题。
- **无损且安全 (自动备份)**：在对系统级 `app.asar` 进行任何修改前，脚本会自动在同目录下创建 `app.asar.bak` 备份文件。如遇问题，随时可以一键恢复。
- **兼容性卓越**：完美适配 **Antigravity v2.0.1** 及以上所有 macOS 桌面版本。

---

## 🛠️ 环境要求

在运行脚本前，请确保您的 Mac 满足以下条件：

1. **操作系统**：macOS (Intel/Apple Silicon 均可)
2. **已安装 Antigravity.app** 并确保其位于 `/Applications/Antigravity.app`。
3. **Python 3**：用于运行汉化翻译逻辑。
   - 可在终端运行 `python3 --version` 验证。
4. **Node.js (含 npx)**：用于提取和重打包 ASAR 文件（脚本会自动通过 `npx` 临时调用 `@electron/asar` 依赖，无需全局安装）。
   - 可在终端运行 `npx -v` 验证。

---

## 🚀 汉化步骤

> [!IMPORTANT]
> **请务必在运行脚本前确保 Antigravity 正在后台运行**（如果是首次安装，请至少启动过一次软件），因为汉化引擎需要从软件的本地活跃端口下载最原始的、未压缩的 `main.js` 前端核心代码进行精确翻译。

### 1. 克隆/下载本仓库到本地

```bash
git clone https://github.com/your-username/antigravity-2.0-zhcn-mac.git
cd antigravity-2.0-zhcn-mac
```

### 2. 赋予脚本执行权限并运行

```bash
chmod +x install_mac.sh
./install_mac.sh
```

### 3. 重启软件生效

汉化完成后，请按照以下步骤重新启动软件：
1. 在 Mac 屏幕左上角菜单栏中点击 **Quit Antigravity**（或使用快捷键 `Cmd + Q`）彻底退出。
2. 重新在 Launchpad / Applications 中打开 **Antigravity**。
3. 尽情享受纯中文的开发体验！🎉

---

## 🔄 卸载或还原

如果您需要恢复为纯英版原厂界面，只需将备份的 `.bak` 文件覆盖回去即可。

打开终端运行以下命令：

```bash
# 恢复原厂 app.asar 备份
cp /Applications/Antigravity.app/Contents/Resources/app.asar.bak /Applications/Antigravity.app/Contents/Resources/app.asar

# 删除汉化缓存文件
rm -f ~/Library/Application\ Support/Antigravity/zh_cn_ui_main.js
```

然后重启 Antigravity 即可。

---

## 📂 仓库结构

- [install_mac.sh](file:///Users/liujunjie/.gemini/antigravity/scratch/antigravity-2.0-zhcn-mac/install_mac.sh) - 一键式全自动化汉化引导与注入主脚本。
- [translate_ui.py](file:///Users/liujunjie/.gemini/antigravity/scratch/antigravity-2.0-zhcn-mac/translate_ui.py) - 核心汉化逻辑与文本映射引擎。
- [customScheme.ai-ui.js](file:///Users/liujunjie/.gemini/antigravity/scratch/antigravity-2.0-zhcn-mac/customScheme.ai-ui.js) - 自定义协议拦截补丁（用于欺骗 Electron 核心，将 `main.js` 的请求智能重定向至我们生成的中文 `zh_cn_ui_main.js`）。

---

## 🤝 鸣谢与声明

- 本项目的核心汉化字典与 Python 翻译引擎基础来自于 Windows 汉化开源项目 [antigravity-2.0-zhcn](https://github.com/kakarotto-baroko/antigravity-2.0-zhcn)。
- 本项目针对 macOS Platform 做了全面的架构重构、ASAR 解包封包适配、以及全自动化脚本支持。
- 本项目仅限交流与个人学习使用。
