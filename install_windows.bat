@echo off
:: ==============================================================================
#    Antigravity 2.0.6+ Windows 自动化汉化注入引导批处理
# ==============================================================================
echo =====================================================
echo    Antigravity Windows 汉化注入工具启动中...
echo =====================================================

:: 检查 PowerShell 运行策略并以 Bypass 执行 ps1 脚本
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_windows.ps1"

if %ERRORLEVEL% neq 0 (
    echo.
    echo [错误] 汉化注入过程中遇到错误，请检查上方报错提示。
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [提示] 汉化注入执行完毕，按任意键退出本窗口...
pause
