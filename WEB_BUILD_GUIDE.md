# Flutter Web 构建指南

## 1. 环境准备

### 安装 Flutter SDK

1. **下载 Flutter SDK**：
   - 访问 https://flutter.dev/docs/get-started/install/windows
   - 下载最新版 Flutter SDK

2. **解压到合适位置**：
   ```bash
   # 例如解压到 C:\src\flutter
   ```

3. **添加 Flutter 到 PATH**：
   - 打开系统环境变量设置
   - 在 PATH 中添加：`C:\src\flutter\bin`

4. **验证安装**：
   ```bash
   flutter --version
   ```

### 安装 Chrome 浏览器
- Flutter Web 需要 Chrome 浏览器进行测试

## 2. 项目修改

### 2.1 修改 pubspec.yaml
将 `sqflite` 依赖替换为 Web 兼容的存储方案：

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  # 替换为 shared_preferences（简单键值存储）
  shared_preferences: ^2.2.2
  # 或者使用 hive（更强大的本地存储）
  # hive: ^2.2.3
  # hive_flutter: ^1.1.0
  path: ^1.8.3
  intl: ^0.19.0
```

### 2.2 创建 Web 兼容的数据库服务
创建 `lib/services/web_database_service.dart`：

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class WebDatabaseService {
  static final WebDatabaseService _instance = WebDatabaseService._internal();
  factory WebDatabaseService() => _instance;
  WebDatabaseService._internal();

  static const String _eventsKey = 'memory_assistant_events';

  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  Future<List<Event>> _getAllEventsFromStorage() async {
    final prefs = await _prefs;
    final eventsJson = prefs.getStringList(_eventsKey) ?? [];
    return eventsJson.map((json) => Event.fromJson(json)).toList();
  }

  Future<void> _saveAllEventsToStorage(List<Event> events) async {
    final prefs = await _prefs;
    final eventsJson = events.map((event) => event.toJson()).toList();
    await prefs.setStringList(_eventsKey, eventsJson);
  }

  Future<int> insertEvent(Event event) async {
    final events = await _getAllEventsFromStorage();
    // 生成新 ID
    final newId = events.isEmpty ? 1 : events.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    event.id = newId;
    events.add(event);
    await _saveAllEventsToStorage(events);
    return newId;
  }

  Future<List<Event>> getAllEvents() async {
    final events = await _getAllEventsFromStorage();
    // 按时间倒序排序
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }

  Future<List<Event>> getEventsByCategory(String category) async {
    final events = await _getAllEventsFromStorage();
    final filtered = events.where((event) => event.category == category).toList();
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

  Future<int> updateEvent(Event event) async {
    final events = await _getAllEventsFromStorage();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await _saveAllEventsToStorage(events);
      return 1;
    }
    return 0;
  }

  Future<int> deleteEvent(int id) async {
    final events = await _getAllEventsFromStorage();
    final initialLength = events.length;
    events.removeWhere((event) => event.id == id);
    if (events.length < initialLength) {
      await _saveAllEventsToStorage(events);
      return 1;
    }
    return 0;
  }

  Future<int> getEventCount() async {
    final events = await _getAllEventsFromStorage();
    return events.length;
  }

  Future<void> close() async {
    // shared_preferences 不需要显式关闭
  }
}
```

### 2.3 修改 Event 模型
在 `lib/models/event.dart` 中添加 JSON 序列化方法：

```dart
class Event {
  // ... 现有代码 ...

  // 添加 JSON 序列化方法
  String toJson() {
    return jsonEncode({
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'who': who,
      'what': what,
      'location': location,
      'why': why,
      'notes': notes,
    });
  }

  factory Event.fromJson(String jsonString) {
    final map = jsonDecode(jsonString);
    return Event(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      category: map['category'],
      who: map['who'],
      what: map['what'],
      location: map['location'],
      why: map['why'],
      notes: map['notes'],
    );
  }
}
```

### 2.4 修改主文件使用条件导入
创建 `lib/services/database_service_factory.dart`：

```dart
import 'package:flutter/foundation.dart';

// 条件导入
DatabaseServiceBase createDatabaseService() {
  if (kIsWeb) {
    return WebDatabaseService();
  } else {
    return DatabaseService();
  }
}

abstract class DatabaseServiceBase {
  Future<int> insertEvent(Event event);
  Future<List<Event>> getAllEvents();
  Future<List<Event>> getEventsByCategory(String category);
  Future<int> updateEvent(Event event);
  Future<int> deleteEvent(int id);
  Future<int> getEventCount();
  Future<void> close();
}
```

然后修改现有的 `database_service.dart` 实现 `DatabaseServiceBase`。

## 3. 构建 Web 版本

### 3.1 启用 Web 支持
```bash
flutter config --enable-web
```

### 3.2 获取依赖
```bash
flutter pub get
```

### 3.3 构建发布版本
```bash
flutter build web --release
```

### 3.4 验证构建
构建完成后，检查以下文件是否存在：
- `build/web/index.html`
- `build/web/main.dart.js`
- `build/web/assets/`

## 4. 运行 Web 应用

### 4.1 本地服务器运行
```bash
# 使用 Flutter 内置服务器
flutter run -d chrome

# 或使用 Python 简单服务器
cd build/web
python -m http.server 8000
# 然后在浏览器中访问 http://localhost:8000
```

### 4.2 直接打开文件
- 在文件资源管理器中打开 `build/web/index.html`
- 使用 Chrome 打开（某些功能可能需要本地服务器）

## 5. 部署到 Web 服务器

1. 将 `build/web` 目录下的所有文件上传到 Web 服务器
2. 确保服务器配置正确（MIME 类型等）
3. 通过 URL 访问应用

## 6. 注意事项

### 6.1 存储限制
- `shared_preferences` 在 Web 上使用 localStorage，有大小限制（通常 5-10MB）
- 对于大量数据，考虑使用 IndexedDB（通过 `idb` 包）

### 6.2 平台差异
- Web 平台不支持某些原生功能
- 文件系统访问受限
- 需要处理跨平台兼容性

### 6.3 性能考虑
- Web 版本首次加载需要下载所有资源
- 考虑代码分割和懒加载
- 优化资源文件大小

## 7. 故障排除

### 7.1 构建失败
- 检查 Flutter 版本：`flutter --version`
- 清理构建缓存：`flutter clean`
- 更新依赖：`flutter pub upgrade`

### 7.2 Web 页面空白
- 检查浏览器控制台错误
- 确保所有资源路径正确
- 验证 CORS 配置（如果部署到不同域）

### 7.3 存储不工作
- 检查浏览器是否禁用 localStorage
- 验证数据序列化/反序列化
- 检查存储空间限制

## 8. 替代方案

如果不想修改代码，可以考虑：

1. **使用 Flutter 的 sqflite_common_ffi**：提供 Web 支持
2. **使用 Firebase**：云存储解决方案
3. **使用 Hive**：高性能的键值存储，支持 Web

## 9. 参考资料

- [Flutter Web 文档](https://flutter.dev/web)
- [shared_preferences 包](https://pub.dev/packages/shared_preferences)
- [Hive 包](https://pub.dev/packages/hive)
- [Flutter 平台特定代码](https://flutter.dev/docs/development/platform-integration/platform-channels)