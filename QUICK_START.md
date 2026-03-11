# Flutter Web 快速开始

## 当前状态分析

### 项目结构
- ✅ Flutter 项目结构完整
- ✅ 包含 Android 和 iOS 配置
- ❌ 缺少 Web 配置
- ❌ 使用不兼容 Web 的依赖 (sqflite)

### 需要修改的内容
1. **依赖替换**: 将 `sqflite` 替换为 Web 兼容的存储方案
2. **代码适配**: 修改数据库服务以支持 Web 平台
3. **构建配置**: 启用 Web 构建支持

## 快速解决方案

### 方案1: 最小修改（推荐）
使用 `shared_preferences` 替换 `sqflite`：

1. **修改 pubspec.yaml**:
   ```yaml
   dependencies:
     shared_preferences: ^2.2.2  # 替换 sqflite
   ```

2. **创建 Web 兼容的数据库服务**（已提供在 WEB_BUILD_GUIDE.md）

3. **使用条件导入**适配多平台

### 方案2: 使用兼容包
使用 `sqflite_common_ffi` 的 Web 版本（如果可用）

### 方案3: 模拟数据（仅测试）
创建模拟数据库服务，不持久化数据

## 构建步骤总结

1. **安装 Flutter**（如果未安装）
   ```
   # 下载并解压 Flutter SDK
   # 添加 C:\src\flutter\bin 到 PATH
   ```

2. **修改项目**（根据上述方案）

3. **构建命令**:
   ```bash
   # 启用 Web 支持
   flutter config --enable-web
   
   # 获取依赖
   flutter pub get
   
   # 构建 Web 版本
   flutter build web --release
   ```

4. **运行测试**:
   ```bash
   # 方法1: Flutter 内置服务器
   flutter run -d chrome
   
   # 方法2: Python 简单服务器
   cd build/web
   python -m http.server 8000
   # 访问 http://localhost:8000
   
   # 方法3: 直接打开
   # 在浏览器中打开 build/web/index.html
   ```

## 预期输出

构建成功后，将在 `build/web/` 目录生成以下文件：
- `index.html` - 主 HTML 文件
- `main.dart.js` - 编译后的 Dart 代码
- `flutter_service_worker.js` - 服务工作者
- `assets/` - 资源文件目录
- `icons/` - 图标文件
- `manifest.json` - Web 应用清单

## 故障排除

### 常见问题1: Flutter 命令未找到
- 解决方案: 确保 Flutter 已安装并添加到 PATH
- 验证: 运行 `flutter --version`

### 常见问题2: 依赖不兼容
- 解决方案: 替换不兼容的包
- 当前问题: `sqflite` 不支持 Web

### 常见问题3: 构建失败
- 解决方案: 清理缓存并重试
  ```bash
  flutter clean
  flutter pub get
  flutter build web --release
  ```

### 常见问题4: Web 页面空白
- 解决方案: 检查浏览器控制台错误
- 可能原因: 资源路径错误、CORS 问题

## 下一步

1. **安装 Flutter SDK**（如果未安装）
2. **按照 WEB_BUILD_GUIDE.md 修改代码**
3. **运行 build_web.bat 或 build_web.ps1**
4. **测试构建结果**

## 联系支持

如果遇到问题，请提供：
1. Flutter 版本 (`flutter --version`)
2. 错误信息截图
3. 控制台输出