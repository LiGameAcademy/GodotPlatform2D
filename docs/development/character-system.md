# 角色系统技术文档

本文档详细介绍了 GodotPlatform2D 项目中角色系统的技术实现。

## 🎯 系统概述

角色系统是一个基于 Godot 4.x 的 2D 平台游戏角色控制系统，具有以下特点：

1. 流畅的移动和跳跃控制
2. 高度可配置的动画系统
3. 基于状态机的行为管理
4. 道具收集和连击系统
5. 支持多角色扩展

## 🔧 核心组件

### 1. 角色基类 (Character)

`Character` 类继承自 `CharacterBody2D`，是整个角色系统的核心。它实现了：

#### 1.1 基础属性

```gdscript
# 移动参数
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var wall_slide_speed = 50

# 动画参数
@export var base_animation_speed = 1.0
@export var max_animation_speed = 1.5
@export var wall_slide_anim_scale = 0.7
@export var speed_scale_factor = 0.5

# 道具收集参数
@export var collection_score = 100
@export var combo_time_window = 2.0
@export var max_combo = 5
```

#### 1.2 主要功能

- **移动系统**：
  - 水平移动控制
  - 跳跃和二段跳
  - 墙壁滑行
  - 穿透平台

- **动画系统**：
  - 基于 AnimationTree 的动画状态机
  - 动态动画速度调整
  - 混合空间过渡

- **道具收集系统**：
  - 连击计数
  - 分数计算
  - 时间窗口管理

### 2. 状态机系统

`CharacterStateMachine` 类管理角色的所有状态：

#### 2.1 状态类型

1. **地面状态 (GroundState)**
   - 处理站立和移动
   - 检测跳跃输入
   - 管理地面动画

2. **空中状态 (AirState)**
   - 处理跳跃和下落
   - 管理二段跳
   - 控制空中动画

3. **墙壁状态 (WallState)**
   - 处理墙壁滑行
   - 管理墙跳
   - 限制下落速度

4. **死亡状态 (DeadState)**
   - 处理角色死亡
   - 播放死亡动画

#### 2.2 状态转换逻辑

- 地面 → 空中：跳跃或离开地面
- 空中 → 地面：着陆
- 空中 → 墙壁：接触墙壁且下落
- 墙壁 → 空中：墙跳或离开墙壁
- 任意 → 死亡：触发死亡条件

## 🎮 控制系统

### 1. 输入处理

- 左右移动：`ui_left`/`ui_right`
- 跳跃：`ui_up`
- 下落穿透：`ui_down`

### 2. 碰撞处理

```gdscript
# 正常碰撞掩码
var normal_mask = (1 << 1) | (1 << 2)
# 穿透碰撞掩码
var pass_through_mask = 1 << 1
```

## 🎨 动画系统

### 1. 动画状态

- Idle：站立
- Move：移动（包含跑动和空中动作）
- DoubleJump：二段跳
- Walled：墙壁滑行
- Desappearing：消失/死亡

### 2. 动画速度控制

```gdscript
var speed_scale = base_animation_speed
if is_moving():
    var speed_factor = abs(velocity.x) / SPEED * speed_scale_factor
    speed_scale = base_animation_speed + speed_factor * (max_animation_speed - base_animation_speed)
```

## 💎 道具收集系统

### 1. 连击机制

- 在时间窗口内收集道具触发连击
- 连击数影响得分倍率
- 超时重置连击数

### 2. 信号系统

```gdscript
signal item_collected(item_type: String, combo: int, score: int)
signal combo_ended(final_combo: int)
```

## 🔄 扩展性

系统支持通过以下方式扩展：

1. **新角色创建**
   - 继承基础角色场景
   - 自定义动画和属性

2. **状态扩展**
   - 添加新的状态类
   - 自定义状态行为和转换

3. **动画定制**
   - 修改动画树
   - 添加新的动画状态
   - 自定义混合空间

## 📈 性能考虑

1. **动画系统优化**
   - 使用动画树减少状态切换开销
   - 动态调整动画更新频率

2. **物理处理优化**
   - 使用适当的碰撞形状
   - 优化碰撞检测

## 🔍 调试功能

1. **导出变量**
   - 所有关键参数都可在编辑器中调整
   - 支持实时修改和测试

2. **状态监控**
   - 可通过信号监控状态变化
   - 支持道具收集数据统计

## 📝 使用示例

1. **创建新角色**

```gdscript
# 继承基础角色场景
extends "res://source/entity/character/character.tscn"

# 自定义参数
@export var custom_speed = 400.0
```

2. **添加新状态**

```gdscript
# 在状态机中添加新状态
class CustomState extends BaseState:
    func _enter(_msg: Dictionary = {}) -> void:
        # 状态进入逻辑
        pass
    
    func _physics_update(_delta: float) -> void:
        # 状态更新逻辑
        pass
```

## 🚀 未来改进

1. **动画系统**
   - 添加更多动画过渡效果
   - 支持动画事件系统

2. **状态机**
   - 添加状态栈系统
   - 支持并行状态

3. **输入系统**
   - 支持自定义按键映射
   - 添加手柄支持

4. **道具系统**
   - 扩展道具类型
   - 添加更复杂的连击系统

## 📚 相关文档

- [角色配置指南](character-configuration.md)
- [动画系统详解](animation-system.md)
- [状态机教程](state-machine.md)
- [API 文档](api.md)
