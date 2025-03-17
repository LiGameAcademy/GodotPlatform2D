# API 文档

本文档详细介绍了 GodotPlatform2D 项目中的主要类和 API。

## 📚 类参考

### Character

角色基类，实现了基本的平台游戏角色功能。

#### 属性

```gdscript
# 移动参数
@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0
@export var wall_slide_speed: float = 50

# 动画参数
@export var base_animation_speed: float = 1.0
@export var max_animation_speed: float = 1.5
@export var wall_slide_anim_scale: float = 0.7
@export var speed_scale_factor: float = 0.5

# 道具收集参数
@export var collection_score: int = 100
@export var combo_time_window: float = 2.0
@export var max_combo: int = 5
```

#### 方法

```gdscript
# 移动控制
func move_and_slide() -> void
func is_moving() -> bool
func is_jumping() -> bool
func is_falling() -> bool

# 动画控制
func play_animation(anim_name: String) -> void
func update_animation_parameters() -> void

# 道具收集
func collect_item(item_type: String) -> void
func get_collection_data() -> Dictionary
```

#### 信号

```gdscript
# 角色事件
signal died
signal item_collected(item_type: String, combo: int, score: int)
signal combo_ended(final_combo: int)
```

### CharacterStateMachine

角色状态机，管理角色的状态转换。

#### 方法

```gdscript
# 状态管理
func add_state(name: StringName, state: BaseState) -> void
func switch_to(state_name: StringName, msg: Dictionary = {}) -> void
func get_current_state() -> BaseState
```

#### 内置状态

```gdscript
# 地面状态
class GroundState:
    func _enter(_msg: Dictionary = {}) -> void
    func _physics_update(_delta: float) -> void

# 空中状态
class AirState:
    func _enter(msg: Dictionary = {}) -> void
    func _physics_update(_delta: float) -> void

# 墙壁状态
class WallState:
    func _enter(_msg: Dictionary = {}) -> void
    func _physics_update(_delta: float) -> void
```

### BaseState

状态基类，定义了状态的基本接口。

#### 方法

```gdscript
# 状态生命周期
func _enter(_msg: Dictionary = {}) -> void
func _exit() -> void
func _physics_update(_delta: float) -> void
func _update(_delta: float) -> void

# 状态转换
func switch_to(state_name: StringName, msg: Dictionary = {}) -> void
```

## 🔧 工具类

### AnimationHelper

动画辅助类，提供动画相关的实用函数。

#### 方法

```gdscript
# 动画控制
static func play_animation(player: AnimationPlayer, name: String) -> void
static func blend_animation(tree: AnimationTree, param: String, value: float) -> void

# 动画状态
static func is_animation_playing(player: AnimationPlayer) -> bool
static func get_current_animation(player: AnimationPlayer) -> String
```

### CollectionManager

道具收集管理器，处理道具收集和计分。

#### 方法

```gdscript
# 收集管理
func collect_item(item_type: String) -> void
func update_combo() -> void
func reset_combo() -> void

# 数据访问
func get_total_score() -> int
func get_current_combo() -> int
```

## 📡 信号系统

### 全局信号

```gdscript
# 游戏状态
signal game_started
signal game_paused
signal game_resumed
signal game_over

# 道具系统
signal item_collected(item_type: String, position: Vector2)
signal combo_achieved(combo: int, score: int)
```

### 角色信号

```gdscript
# 状态变化
signal state_changed(old_state: String, new_state: String)
signal animation_changed(anim_name: String)

# 碰撞事件
signal hit_wall
signal hit_ceiling
signal landed
```

## 🎮 输入系统

### 默认按键映射

```gdscript
# 移动控制
"ui_left": 左方向键/A键
"ui_right": 右方向键/D键
"ui_up": 上方向键/W键/空格键
"ui_down": 下方向键/S键

# 动作控制
"jump": 空格键
"attack": J键
"interact": E键
```

## 💾 存储系统

### 游戏数据

```gdscript
# 玩家数据结构
class PlayerData:
    var score: int
    var collected_items: Array
    var unlocked_characters: Array

# 关卡数据结构
class LevelData:
    var high_score: int
    var completion_time: float
    var collected_secrets: Array
```

## 🔍 调试 API

### 调试命令

```gdscript
# 角色调试
func toggle_invincible() -> void
func set_speed_multiplier(multiplier: float) -> void
func teleport_to(position: Vector2) -> void

# 状态调试
func print_state_info() -> void
func force_state(state_name: String) -> void
```

### 调试可视化

```gdscript
# 显示调试信息
func draw_debug_info() -> void
func show_collision_shapes() -> void
func show_state_machine() -> void
```

## 🎨 资源管理

### 预加载资源

```gdscript
# 动画资源
var ANIMATIONS = {
    "idle": preload("res://animations/idle.tres"),
    "run": preload("res://animations/run.tres"),
    "jump": preload("res://animations/jump.tres")
}

# 音效资源
var SOUNDS = {
    "jump": preload("res://sounds/jump.wav"),
    "land": preload("res://sounds/land.wav"),
    "collect": preload("res://sounds/collect.wav")
}
```

## 🔧 工具函数

### 数学工具

```gdscript
# 向量操作
func lerp_vector2(from: Vector2, to: Vector2, weight: float) -> Vector2
func angle_to_vector2(angle: float) -> Vector2

# 数值处理
func approach(current: float, target: float, delta: float) -> float
func wrap_angle(angle: float) -> float
```

### 游戏工具

```gdscript
# 游戏状态
func pause_game() -> void
func resume_game() -> void
func restart_level() -> void

# 场景管理
func change_scene(scene_path: String) -> void
func reload_current_scene() -> void
```

## 📝 使用示例

### 创建自定义角色

```gdscript
extends Character

func _ready() -> void:
    # 自定义参数
    SPEED = 400.0
    JUMP_VELOCITY = -450.0
    
    # 添加自定义状态
    var state_machine = get_node("StateMachine")
    state_machine.add_state(&"custom", CustomState.new())
```

### 实现新状态

```gdscript
class CustomState extends BaseState:
    func _enter(msg: Dictionary = {}) -> void:
        agent.play_animation("Custom")
    
    func _physics_update(delta: float) -> void:
        # 实现状态逻辑
        if condition:
            switch_to(&"next_state")
```

## 🔍 API 版本历史

### v0.2.0 (2025-03-17)

- 添加道具收集系统
- 优化动画状态机
- 改进碰撞检测

### v0.1.0 (2025-03-01)

- 基础角色控制
- 状态机实现
- 动画系统基础

## 📚 相关文档

- [角色配置指南](character-configuration.md)
- [动画系统详解](animation-system.md)
- [状态机教程](state-machine.md)
- [Godot 官方文档](https://docs.godotengine.org/)
