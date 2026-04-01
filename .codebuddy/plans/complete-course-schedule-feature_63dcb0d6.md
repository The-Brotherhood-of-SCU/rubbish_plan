---
name: complete-course-schedule-feature
overview: 实现混沌课表项目的核心课表功能，包括课程数据模型、本地持久化、状态管理、课表网格视图、课程增删改、课表设置页面（学期日期/节数/时间段/显示设置），以及相关国际化支持。
todos:
  - id: add-i18n
    content: 为课表功能添加国际化字符串到 app_en.arb ，其他语言先不用管
    status: completed
  - id: impl-models
    content: 实现 Course、TimeSlot、ScheduleConfig 数据模型及 JSON 序列化（lib/models/course.dart）或者sqlite储存
    status: completed
    dependencies:
      - add-i18n
  - id: impl-database-service
    content: 实现 DatabaseService 持久化服务（lib/serivces/database_service.dart），并在 injector.dart 中注册
    status: completed
    dependencies:
      - impl-models
  - id: impl-course-provider
    content: 实现 CourseProvider 状态管理（lib/providers/course_provider.dart），扩展 AppConfigProvider.clearAll()
    status: completed
    dependencies:
      - impl-database-service
  - id: impl-course-grid
    content: 实现课表网格组件 course_grid.dart 和课程卡片，完成 course_page.dart 网格视图
    status: completed
    dependencies:
      - impl-course-provider
  - id: impl-course-edit
    content: 实现课程添加/编辑表单页 course_edit_page.dart，连接到 course_page.dart 的添加和编辑功能
    status: completed
    dependencies:
      - impl-course-grid
  - id: impl-schedule-setting
    content: 实现课表设置页面内容（学期配置、节数配置、时间段配置、显示设置）
    status: completed
    dependencies:
      - impl-course-provider
---

## 用户需求

完成 Flutter 课表项目（混沌课表/rubbish_plan）的核心功能开发。项目基础框架已搭建完成（设置系统、国际化、路由、自适应布局），但课表核心业务功能完全未实现。

## 产品概述

一款简洁实用的课程管理应用，支持自定义课表时间结构、手动添加/编辑/删除课程、学期管理、课表网格展示和课表设置。

## 核心功能

### 1. 课程数据模型与持久化

- 定义课程数据结构：课程名、教师、教室、上课时间（周范围/星期/起始节次-结束节次）、课程颜色
- 定义课表配置模型：学期起止日期、每天节数、每节课时间段
- 使用 JSON 文件实现课程数据和课表配置的持久化

### 2. 课程表页面

- 网格视图展示周课表（横轴周一至周日，纵轴各节次），显示当前周数，支持左右滑动切换周
- 课程卡片显示课程名、教室、教师，背景为课程颜色
- 点击空白区域添加课程，点击课程卡片编辑课程
- 长按课程卡片弹出删除选项
- 下载和发送按钮保留为占位

### 3. 课程编辑页面

- 表单包含：课程名称、教师、教室、课程颜色选择
- 时间选择：周范围（起止周）、星期、节次范围（起始-结束节次，结束节次大于起始节次时跨天处理）
- 支持"已存在课程时添加新时间"的提示
- 预设颜色选择 + 自定义颜色

### 4. 课表设置页面

- 学期名称、学期起止日期配置
- 每天节数配置（数字输入）
- 每节课时间段配置（开始时间和结束时间列表）
- 显示设置：课程颜色不透明度、字体大小等

### 5. 国际化

- 为所有新增功能补充中英文翻译

## 技术栈

- **框架**: Flutter (Dart SDK ^3.10.4)
- **状态管理**: ValueNotifier + GetIt（与现有项目一致）
- **持久化**: 轻量数据如配置采用 SharedPreferences（使用现有的 `shared_preferences` 依赖）重量数据如课表采用sqflite 进行管理
- **UI 组件**: Material Design 3 组件 + 现有自定义组件（`StyledCard`、`TitleText` 等）
- **弹窗/导航**: 复用现有 `popupOrNavigate` / `showYesNoDialog` 系统

## 实现方案

### 核心架构：三层分层

采用与现有项目完全一致的分层架构：

- **Model 层**: 数据模型（`Course`、`TimeSlot`、`ScheduleConfig`），使用 `json_serializable` 或手动 `toJson`/`fromJson`
- **Service 层**: `DatabaseService` 封装 JSON 持久化，通过 SharedPreferences 存储 、sqflite 的课表数据查询
- **Provider 层**: `CourseProvider` 持有 `ValueNotifier`，管理课程数据加载、CRUD 和当前周状态
- **Page 层**: UI 页面，通过 `getIt<CourseProvider>()` 获取状态

### 数据模型设计

```
// Course: 课程
// - String id (UUID)
// - String name (课程名)
// - String teacher (教师)
// - String location (教室)
// - int startWeek, int endWeek (周范围 1-based)
// - int dayOfWeek (1=周一 ... 7=周日)
// - int startSection, int endSection (节次范围 1-based)
// - int colorValue (ARGB int)

// ScheduleConfig: 课表时间配置
// - String semesterName
// - DateTime semesterStartDate, semesterEndDate
// - int sectionsPerDay (每天节数)
// - List<TimeSlot> timeSlots (每节课时间段)
// - double colorOpacity (课程颜色不透明度)

// TimeSlot: 时间段
// - TimeOfDay startTime, endTime

// CourseScheduleSettingData: 课表显示设置
// - double courseCardFontSize
// - bool showTeacherName
// - bool showLocation
```

### 课表网格渲染策略

- 使用 `CustomScrollView` + `SliverGrid` 或手动布局（`Column` + `Row` + `Expanded` + `Stack`）
- 时间轴列（固定宽度，显示节次和时间）+ 7天列（均分宽度）
- 每个课程使用 `Positioned` 嵌入对应单元格区域
- 课程卡片颜色使用配置中的不透明度值叠加

### 当前周计算

根据学期起始日期和当前日期计算当前周数：`(currentDate.difference(startDate).inDays / 7).floor() + 1`

### 持久化策略

- 课程列表：`SharedPreferences` 存储 JSON 字符串，key 为 `'courses'`
- 课表配置：`SharedPreferences` 存储 JSON 字符串，key 为 `'scheduleConfig'`
- 课程数据量小（通常不超过 50 条），JSON 方案足够且无需引入额外数据库依赖

### 依赖注入

在 `lib/injection/injector.dart` 中注册：

- `DatabaseService` 依赖 `SharedPreferences`（异步单例）
- `CourseProvider` 依赖 `DatabaseService`（异步单例）

## 实现注意事项

- **保持现有目录结构**: `serivces/` 拼写不做修改，新文件 `database_service.dart` 放在 `lib/serivces/` 下
- **遵循 ValueNotifier 模式**: 与 `AppConfigProvider` 保持一致的监听器-持久化模式
- **国际化 ARB 需同步更新**: 修改 `app_en.arb` 和 `app_zh.arb`，并手动更新 `app_localizations*.dart` 生成文件（保持现有手动模式）
- **`clearAll` 需扩展**: `AppConfigProvider.clearAll()` 应同时清除课程数据（通过 CourseProvider）
- **避免引入新依赖**: 不使用 `json_serializable`，手动实现序列化以避免构建步骤

## 目录结构

```
lib/
├── models/
│   └── course.dart              # [MODIFY] 课程数据模型、TimeSlot、ScheduleConfig 及序列化
├── providers/
│   ├── app_config_provider.dart  # [MODIFY] clearAll 扩展
│   └── course_provider.dart      # [MODIFY] 课程状态管理（CRUD、当前周、通知监听）
├── serivces/
│   └── database_service.dart     # [MODIFY] JSON 持久化服务（课程数据 + 课表配置）
├── pages/
│   ├── course_page.dart          # [MODIFY] 替换 Placeholder 为课表网格视图
│   ├── course_edit_page.dart     # [NEW] 课程添加/编辑表单页
│   └── course_schedule_setting.dart  # [MODIFY] 替换 Placeholder 为课表设置内容
├── widgets/
│   └── course/
│       └── course_grid.dart      # [NEW] 课表网格组件（时间轴 + 7天列 + 课程卡片）
├── injection/
│   └── injector.dart             # [MODIFY] 注册 DatabaseService 和 CourseProvider
├── l10n/
│   ├── app_en.arb                # [MODIFY] 新增课程相关翻译
│   ├── app_zh.arb                # [MODIFY] 新增课程相关翻译
│   ├── app_localizations.dart    # [MODIFY] 新增抽象方法
│   ├── app_localizations_en.dart # [MODIFY] 英文实现
│   └── app_localizations_zh.dart # [MODIFY] 中文实现
```

## Agent Extensions

### Skill

- **Flutter 开发**
- Purpose: 指导 Flutter 跨平台开发，包括 widget 模式、状态管理、性能优化等
- Expected outcome: 确保课表网格布局、ValueNotifier 状态管理、持久化逻辑等实现符合 Flutter 最佳实践

### SubAgent

- **code-explorer**
- Purpose: 在实现过程中搜索和验证现有代码模式、依赖关系
- Expected outcome: 确保新代码与现有架构模式完全一致