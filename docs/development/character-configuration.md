# 角色配置指南

本文档详细介绍如何配置和自定义角色系统中的各项参数。

## 🎮 基础设置

### 1. 场景结构

角色场景的基本结构如下：
```
Character (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D
├── AnimationPlayer
└── AnimationTree
```

### 2. 必要组件

1. **碰撞形状**
   - 推荐使用 `CapsuleShape2D`
   - 适当调整大小以匹配角色精灵

2. **精灵节点**
   - 确保精灵图片朝向正确
   - 设置适当的 Offset 使角色居中

3. **动画播放器**
   - 创建基础动画集：Idle、Move、Jump 等
   - 设置适当的帧率和循环属性

4. **动画树**
   - 配置状态机
   - 设置混合空间
   - 添加过渡条件

## ⚙️ 导出参数

### 1. 移动参数

```gdscript
# 基础移动速度
@export var SPEED = 300.0
# 建议范围：200-400
# 影响：影响角色的移动速度和游戏节奏

# 跳跃力度
@export var JUMP_VELOCITY = -400.0
# 建议范围：-300 到 -500
# 影响：决定跳跃高度，注意与重力配合

# 墙滑速度
@export var wall_slide_speed = 50
# 建议范围：30-70
# 影响：决定角色在墙上下滑的速度
```

### 2. 动画参数

```gdscript
# 基础动画速度
@export var base_animation_speed = 1.0
# 建议范围：0.8-1.2
# 影响：角色的基础动画播放速度

# 最大动画速度
@export var max_animation_speed = 1.5
# 建议范围：1.3-2.0
# 影响：角色移动时的最大动画速度

# 墙滑动画缩放
@export var wall_slide_anim_scale = 0.7
# 建议范围：0.5-0.9
# 影响：墙壁滑行时的动画速度

# 速度影响因子
@export var speed_scale_factor = 0.5
# 建议范围：0.3-0.7
# 影响：移动速度对动画速度的影响程度
```

### 3. 道具收集参数

```gdscript
# 基础分数
@export var collection_score = 100
# 建议范围：50-200
# 影响：每个道具的基础得分

# 连击时间窗口
@export var combo_time_window = 2.0
# 建议范围：1.5-3.0
# 影响：维持连击的时间长度

# 最大连击数
@export var max_combo = 5
# 建议范围：3-10
# 影响：最大可达到的连击倍率
```

## 🎨 动画配置

### 1. 动画状态机设置

1. **创建状态**
   - Idle：循环播放
   - Move：使用混合空间
   - Jump：单次播放
   - Fall：循环播放
   - Wall：循环播放

2. **设置转换条件**
   ```
   Idle <-> Move：is_moving
   Idle/Move -> Jump：is_jumping
   Jump -> Fall：velocity.y > 0
   Any -> Wall：is_on_wall
   ```

### 2. 混合空间配置

1. **创建参数**
   - X轴：水平速度 (-1 到 1)
   - Y轴：垂直速度 (-1 到 1)

2. **动画点位置**
   ```
   (-1, 0)：向左跑
   (1, 0)：向右跑
   (0, -1)：跳跃
   (0, 1)：下落
   ```

## 🛠️ 调试技巧

### 1. 移动调试

1. **使用远程场景**
   - 在单独的场景中测试角色
   - 添加各种地形进行测试

2. **显示调试信息**
   ```gdscript
   func _draw() -> void:
       # 显示速度向量
       draw_line(Vector2.ZERO, velocity / 10, Color.GREEN)
       # 显示状态信息
       draw_string(font, Vector2(0, -50), current_state)
   ```

### 2. 动画调试

1. **使用动画树调试器**
   - 监视状态转换
   - 检查参数值

2. **添加视觉辅助**
   ```gdscript
   func _process(_delta: float) -> void:
       # 显示动画速度
       print("Animation Speed: ", _animation_tree.get("parameters/TimeScale"))
       # 显示当前状态
       print("Current State: ", _animation_state_machine.get_current_node())
   ```

## 🔧 常见问题

### 1. 移动问题

1. **角色漂移**
   - 检查摩擦力设置
   - 确保停止时速度正确归零

2. **跳跃不稳定**
   - 调整重力和跳跃力
   - 检查碰撞检测

### 2. 动画问题

1. **动画闪烁**
   - 检查状态转换条件
   - 确保动画长度合适

2. **速度不匹配**
   - 调整速度影响因子
   - 检查动画播放速率

## 📝 最佳实践

1. **参数调整**
   - 渐进式调整，每次改动一个参数
   - 记录最佳参数组合

2. **动画设置**
   - 保持动画过渡流畅
   - 避免过多的状态切换

3. **性能优化**
   - 使用适当的碰撞形状
   - 优化动画更新频率

## 🎯 示例配置

### 1. 标准平台角色

```gdscript
# 移动参数
SPEED = 300.0
JUMP_VELOCITY = -400.0
wall_slide_speed = 50

# 动画参数
base_animation_speed = 1.0
max_animation_speed = 1.5
wall_slide_anim_scale = 0.7
speed_scale_factor = 0.5

# 道具参数
collection_score = 100
combo_time_window = 2.0
max_combo = 5
```

### 2. 高速角色

```gdscript
# 移动参数
SPEED = 400.0
JUMP_VELOCITY = -450.0
wall_slide_speed = 70

# 动画参数
base_animation_speed = 1.2
max_animation_speed = 1.8
wall_slide_anim_scale = 0.8
speed_scale_factor = 0.6

# 道具参数
collection_score = 150
combo_time_window = 1.5
max_combo = 7
```

## 📚 相关资源

- [Godot 物理系统文档](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html)
- [动画树教程](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html)
- [输入系统指南](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html)
