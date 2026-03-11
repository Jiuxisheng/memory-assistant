@echo off
echo ========================================
echo Flutter Web 构建脚本
echo ========================================
echo.

echo 步骤1: 检查 Flutter 环境
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Flutter 未安装或未添加到 PATH
    echo 请先安装 Flutter SDK 并添加到系统 PATH
    echo 下载地址: https://flutter.dev/docs/get-started/install/windows
    echo.
    pause
    exit /b 1
)

echo [成功] Flutter 已安装
flutter --version
echo.

echo 步骤2: 启用 Web 支持
flutter config --enable-web
echo.

echo 步骤3: 检查项目目录
if not exist "pubspec.yaml" (
    echo [错误] 未找到 pubspec.yaml，请确保在项目根目录运行
    pause
    exit /b 1
)

echo 步骤4: 安装依赖
echo 正在获取依赖包...
flutter pub get
if %errorlevel% neq 0 (
    echo [错误] 依赖安装失败
    pause
    exit /b 1
)

echo 步骤5: 构建 Web 版本
echo 正在构建 Web 发布版本...
flutter build web --release
if %errorlevel% neq 0 (
    echo [错误] 构建失败
    echo.
    echo 可能的原因:
    echo 1. 依赖不兼容 Web 平台
    echo 2. 需要修改代码以支持 Web
    echo 3. Flutter 版本不兼容
    echo.
    echo 请参考 WEB_BUILD_GUIDE.md 中的解决方案
    pause
    exit /b 1
)

echo 步骤6: 验证构建结果
if exist "build\web\index.html" (
    echo [成功] 构建完成!
    echo.
    echo 构建结果位于: build\web\
    echo.
    echo 文件列表:
    dir /b "build\web\"
    echo.
    echo 如何运行:
    echo 1. 使用本地服务器: python -m http.server 8000
    echo 2. 直接打开: file:///%CD%\build\web\index.html
    echo 3. 使用 Flutter: flutter run -d chrome
) else (
    echo [警告] index.html 未找到，构建可能有问题
)

echo.
echo ========================================
echo 构建完成
echo ========================================
pause