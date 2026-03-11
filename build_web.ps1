Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter Web 构建脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 步骤1: 检查 Flutter 环境
Write-Host "步骤1: 检查 Flutter 环境" -ForegroundColor Yellow
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterPath) {
    Write-Host "[错误] Flutter 未安装或未添加到 PATH" -ForegroundColor Red
    Write-Host "请先安装 Flutter SDK 并添加到系统 PATH"
    Write-Host "下载地址: https://flutter.dev/docs/get-started/install/windows"
    Write-Host ""
    Read-Host "按 Enter 退出"
    exit 1
}

Write-Host "[成功] Flutter 已安装" -ForegroundColor Green
flutter --version
Write-Host ""

# 步骤2: 启用 Web 支持
Write-Host "步骤2: 启用 Web 支持" -ForegroundColor Yellow
flutter config --enable-web
Write-Host ""

# 步骤3: 检查项目目录
Write-Host "步骤3: 检查项目目录" -ForegroundColor Yellow
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "[错误] 未找到 pubspec.yaml，请确保在项目根目录运行" -ForegroundColor Red
    Read-Host "按 Enter 退出"
    exit 1
}

# 步骤4: 安装依赖
Write-Host "步骤4: 安装依赖" -ForegroundColor Yellow
Write-Host "正在获取依赖包..."
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 依赖安装失败" -ForegroundColor Red
    Read-Host "按 Enter 退出"
    exit 1
}

# 步骤5: 构建 Web 版本
Write-Host "步骤5: 构建 Web 版本" -ForegroundColor Yellow
Write-Host "正在构建 Web 发布版本..."
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 构建失败" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因:" -ForegroundColor Yellow
    Write-Host "1. 依赖不兼容 Web 平台"
    Write-Host "2. 需要修改代码以支持 Web"
    Write-Host "3. Flutter 版本不兼容"
    Write-Host ""
    Write-Host "请参考 WEB_BUILD_GUIDE.md 中的解决方案" -ForegroundColor Yellow
    Read-Host "按 Enter 退出"
    exit 1
}

# 步骤6: 验证构建结果
Write-Host "步骤6: 验证构建结果" -ForegroundColor Yellow
if (Test-Path "build\web\index.html") {
    Write-Host "[成功] 构建完成!" -ForegroundColor Green
    Write-Host ""
    Write-Host "构建结果位于: build\web\" -ForegroundColor Green
    Write-Host ""
    Write-Host "文件列表:" -ForegroundColor Yellow
    Get-ChildItem "build\web\" -Name
    Write-Host ""
    Write-Host "如何运行:" -ForegroundColor Yellow
    Write-Host "1. 使用本地服务器: python -m http.server 8000"
    Write-Host "2. 直接打开: file:///$PWD/build/web/index.html"
    Write-Host "3. 使用 Flutter: flutter run -d chrome"
} else {
    Write-Host "[警告] index.html 未找到，构建可能有问题" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "构建完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Read-Host "按 Enter 退出"