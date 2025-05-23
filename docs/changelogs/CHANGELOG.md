# 更新日志

本文档记录了 GodotPlatform2D 项目的所有重要更改。格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

## 🚀 计划中的功能

- [x] 输入重映射和游戏设置
- [ ] 存档系统
- [x] 计分系统
- [ ] 角色差异化设计
- [ ] 音乐和音效
- [ ] 传送门系统
- [ ] 更多场景机关
- [ ] 更多关卡设计
- [ ] 更多敌人和AI设计
- [ ] 多人联机合作
- [ ] 对抗玩法设计

## [未发布] - 2025-03-27

### 新增

- 新增积分系统功能实现，包括关卡分数和总分
  - 包括一个特效（得分显示的漂字效果）
  - 对事件总线的封装[`GameEvents`](/source/core/game_events.gd)
- 新增快速存档功能
- 添加背景音乐，使用core_system插件

### 变更

- 更改 `trap_rock_head.gd` 中的代码，使用状态机管理器

### 废弃

### 移除

- 更改 `trap_rock_head.gd` 中的代码。不再使用`state_charts`插件

### 修复

- 修复关卡2中的`trap_saw_path`不移动的问题

### 安全

## [v0.0.2] - 2025-03-25

### 架构优化

- 重构游戏流程管理
  - 新增 `GameInstance` 单例，统一管理游戏全局状态
  - 新增 `GameFlowStateMachine`，实现清晰的游戏状态流转
  - 优化场景切换逻辑，支持角色选择、关卡选择等功能
  - 改进游戏启动和初始化流程

- 重构角色系统
  - 将角色拆分为 `Character` 和 `CharacterController` 两个部分
  - 实现 `PlayerController` 处理玩家输入
  - 支持角色预览模式
  - 优化角色状态机实现

### 输入系统

- 集成 `core_system` 插件的 `InputManager`
  - 实现输入缓冲系统，提升游戏手感
  - 支持输入重映射和配置保存
  - 添加虚拟轴和虚拟按键支持
  - 优化输入事件处理流程

### 工具改进

- 新增 `FrameSplitter` 工具类
  - 支持将耗时操作分散到多帧执行
  - 提供进度反馈和完成事件
  - 支持多种处理模式（数组、范围、迭代器等）
  - 动态调整每帧处理量

### 性能优化

- 优化角色动画系统
- 改进输入处理效率
- 优化场景加载性能

## [v0.0.1] - 2025-03-17

### ✨ 新增功能

- 优化角色动画系统
  - 使用 AnimationTree 实现更流畅的动画过渡
  - 添加动画混合空间
  - 实现动态动画速度调整
- 实现道具收集系统
  - 添加连击系统
  - 实现计分系统
  - 优化收集特效

### 🔧 优化改进

- 重构角色动画状态机
- 优化水果类的实现
- 改进代码组织结构

### 📝 文档更新

- 添加双语 README
- 更新项目许可证
- 完善开发文档

详细信息请查看 [2025-03-17-character-and-items.md](2025-03-17-character-and-items.md)

## [v0.0.0] - 2025-03-01

### ✨ 初始功能

- 基础角色控制系统
- 简单的关卡系统
- 基础的动画系统
- 简单的游戏菜单

## 更新日志分类

我们使用以下图标来分类更新内容：

- ✨ 新增功能
- 🔧 优化改进
- 🐛 问题修复
- 📝 文档更新
- 🎨 界面优化
- 🔥 移除功能
- ⚡️ 性能优化
- 🚀 重要更新
- 🔒 安全更新

## 贡献指南

1. 每个重要更新都应该创建一个单独的更新日志文件，放在 `docs/changelogs/` 目录下
2. 文件命名格式：`YYYY-MM-DD-feature-name.md`
3. 在主更新日志（本文件）中添加对应版本的简要说明
4. 在具体的更新日志文件中提供详细的更改说明

## 相关文档

- [项目主页](../../readme.md)
- [开发文档](../development.md)
- [API文档](../api.md)
