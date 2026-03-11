# 修复建议和步骤

## 1. 数据库字段名修复

### 问题
`where` 是 SQL 保留字，作为字段名可能导致问题。

### 解决方案
将 `where` 字段重命名为 `location`。

### 修改步骤

#### 1.1 修改 event.dart
```dart
class Event {
  int? id;
  final DateTime timestamp;
  final String category;
  final String who;
  final String what;
  final String location;  // 修改这里
  final String why;
  final String notes;

  Event({
    this.id,
    required this.timestamp,
    required this.category,
    required this.who,
    required this.what,
    required this.location,  // 修改这里
    required this.why,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'who': who,
      'what': what,
      'location': location,  // 修改这里
      'why': why,
      'notes': notes,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      category: map['category'],
      who: map['who'],
      what: map['what'],
      location: map['location'],  // 修改这里
      why: map['why'],
      notes: map['notes'],
    );
  }
}
```

#### 1.2 修改 database_service.dart
```dart
Future<void> _createDatabase(Database db, int version) async {
  await db.execute('''
    CREATE TABLE events(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp TEXT NOT NULL,
      category TEXT NOT NULL,
      who TEXT NOT NULL,
      what TEXT NOT NULL,
      location TEXT NOT NULL,  // 修改这里
      why TEXT NOT NULL,
      notes TEXT
    )
  ''');
}
```

#### 1.3 修改 input_dialog.dart
```dart
// 修改标签文本
_buildTextField(_locationController, '地点 (Where)', '例如：公司会议室');
```

#### 1.4 修改 event_card.dart
```dart
// 修改显示
_buildInfoRow('📍', '地点', event.location);  // 修改这里
```

## 2. Android 配置修复

### 问题
Android 目录配置不完整。

### 解决方案
创建必要的 Android 配置文件。

### 创建文件

#### 2.1 android/app/build.gradle
```gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    namespace "com.example.memory_assistant"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.example.memory_assistant"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
```

#### 2.2 android/app/src/main/AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="Memory Assistant"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## 3. Flutter 环境配置

### 步骤
1. 下载 Flutter SDK
2. 解压到合适目录（如 C:\flutter）
3. 添加环境变量：
   - 系统变量 Path 添加：C:\flutter\bin
4. 运行 `flutter doctor` 检查环境
5. 安装 Android Studio 和 Android SDK

### 验证命令
```bash
flutter --version
flutter doctor
```

## 4. 构建和测试步骤

### 4.1 获取依赖
```bash
cd C:\Users\HASEE\.openclaw\workspace\memory_assistant
flutter pub get
```

### 4.2 清理构建
```bash
flutter clean
```

### 4.3 构建 APK
```bash
flutter build apk --release
```

### 4.4 检查 APK
```bash
# 查看 APK 路径
dir build\app\outputs\flutter-apk\

# 查看 APK 大小
(Get-Item build\app\outputs\flutter-apk\app-release.apk).Length / 1MB
```

## 5. 测试验证清单

### 功能测试
- [ ] 添加事件（填写5W字段）
- [ ] 分类筛选（健康/社交/工作/其他）
- [ ] 时间线显示（倒序）
- [ ] 数据持久化（关闭重开App数据还在）

### 界面测试
- [ ] 聊天式输入界面正常
- [ ] 事件卡片显示完整
- [ ] 分类标签颜色正确

### 构建测试
- [ ] flutter pub get 成功
- [ ] flutter build apk --release 成功
- [ ] APK 文件大小 < 100MB
- [ ] APK 可以安装运行

## 6. 预期结果

### 修复后
- ✅ 数据库操作正常，无保留字冲突
- ✅ Android 项目配置完整，可以构建
- ✅ Flutter 环境配置正确，可以运行和构建
- ✅ APK 文件生成成功，大小合理

### 测试通过标准
- 所有功能测试项通过
- 所有界面测试项通过
- 构建测试成功完成
- APK 文件可以正常安装运行