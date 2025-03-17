# 状态机教程

本文档详细介绍了 GodotPlatform2D 项目中状态机的实现和使用方法。

## 🎯 概述

状态机是一个用于管理游戏对象不同状态的系统。在我们的项目中，主要用于管理角色的不同状态（如待机、移动、跳跃等）。

## 🔧 基础架构

### 1. 基础状态类

```gdscript
class_name BaseState
extends Node

var state_machine: BaseStateMachine
var agent: Node

func _enter(_msg: Dictionary = {}) -> void:
    pass

func _exit() -> void:
    pass

func _physics_update(_delta: float) -> void:
    pass

func _update(_delta: float) -> void:
    pass

func switch_to(state_name: StringName, msg: Dictionary = {}) -> void:
    state_machine.switch_to(state_name, msg)
```

### 2. 状态机类

```gdscript
class_name BaseStateMachine
extends Node

var current_state: BaseState
var states: Dictionary = {}
var agent: Node

func _ready() -> void:
    for child in get_children():
        if child is BaseState:
            states[child.name.to_lower()] = child
            child.state_machine = self
            child.agent = agent

func switch_to(state_name: StringName, msg: Dictionary = {}) -> void:
    if current_state:
        current_state._exit()
    
    current_state = states[state_name]
    current_state._enter(msg)
```

## 💡 状态实现

### 1. 地面状态

```gdscript
class GroundState extends BaseState:
    func _enter(_msg: Dictionary = {}) -> void:
        agent.can_double_jump = true
        agent.play_animation("Idle")
    
    func _physics_update(_delta: float) -> void:
        if not agent.is_on_floor():
            switch_to(&"air")
        elif agent.is_jumping():
            switch_to(&"air", {"jump": true})
```

### 2. 空中状态

```gdscript
class AirState extends BaseState:
    func _enter(msg: Dictionary = {}) -> void:
        if msg.get("jump", false):
            agent.velocity.y = agent.JUMP_VELOCITY
    
    func _physics_update(_delta: float) -> void:
        if agent.is_on_floor():
            switch_to(&"ground")
        elif agent.is_on_wall():
            switch_to(&"wall")
```

## 🎮 使用方法

### 1. 创建新状态

```gdscript
# 创建自定义状态
class CustomState extends BaseState:
    # 状态进入时的逻辑
    func _enter(_msg: Dictionary = {}) -> void:
        # 初始化状态
        agent.play_animation("Custom")
    
    # 物理更新
    func _physics_update(_delta: float) -> void:
        # 处理状态逻辑
        if some_condition:
            switch_to(&"other_state")
    
    # 状态退出时的逻辑
    func _exit() -> void:
        # 清理状态
        agent.stop_animation()
```

### 2. 注册状态

```gdscript
# 在状态机中注册状态
func _ready() -> void:
    # 添加基础状态
    add_state(&"ground", GroundState.new())
    add_state(&"air", AirState.new())
    add_state(&"wall", WallState.new())
    
    # 添加自定义状态
    add_state(&"custom", CustomState.new())
```

## 🔄 状态转换

### 1. 转换规则

```gdscript
# 定义状态转换规则
func _handle_state_transition() -> void:
    match current_state.name:
        "ground":
            if not is_on_floor():
                switch_to(&"air")
        "air":
            if is_on_floor():
                switch_to(&"ground")
            elif is_on_wall():
                switch_to(&"wall")
```

### 2. 转换消息

```gdscript
# 使用转换消息传递数据
func _handle_jump() -> void:
    switch_to(&"air", {
        "jump": true,
        "force": jump_force,
        "direction": input_direction
    })
```

## 📊 调试功能

### 1. 状态监视

```gdscript
# 添加调试信息
func _process(_delta: float) -> void:
    if OS.is_debug_build():
        print("Current State: ", current_state.name)
        print("Time in State: ", time_in_current_state)
        print("Previous State: ", previous_state.name)
```

### 2. 可视化工具

```gdscript
# 状态可视化
func _draw() -> void:
    if Engine.is_editor_hint():
        var state_text = "State: %s" % current_state.name
        draw_string(font, Vector2(0, -50), state_text)
```

## 🔍 状态数据

### 1. 状态信息

```gdscript
# 状态信息结构
class StateInfo:
    var name: String
    var transitions: Array
    var animation: String
    var can_interrupt: bool
```

### 2. 转换数据

```gdscript
# 转换数据结构
class TransitionInfo:
    var from_state: String
    var to_state: String
    var conditions: Array
    var priority: int
```

## ⚡ 性能优化

### 1. 更新优化

```gdscript
# 优化状态更新
func _physics_process(delta: float) -> void:
    if current_state and agent.is_active():
        current_state._physics_update(delta)
```

### 2. 转换优化

```gdscript
# 优化状态转换
func _optimize_transition() -> void:
    # 缓存常用状态
    var cached_states = {}
    for state_name in ["ground", "air", "wall"]:
        cached_states[state_name] = states[state_name]
```

## 📝 最佳实践

### 1. 状态设计

- 保持状态简单明确
- 避免状态过多
- 合理划分状态职责

### 2. 转换逻辑

- 明确转换条件
- 避免循环转换
- 处理异常情况

### 3. 代码组织

- 使用清晰的命名
- 合理组织状态文件
- 保持代码简洁

## 🚀 高级特性

### 1. 状态栈

```gdscript
# 实现状态栈
class StateMachine:
    var state_stack: Array = []
    
    func push_state(state_name: String) -> void:
        if current_state:
            state_stack.push_back(current_state)
        switch_to(state_name)
    
    func pop_state() -> void:
        if state_stack.size() > 0:
            switch_to(state_stack.pop_back().name)
```

### 2. 并行状态

```gdscript
# 实现并行状态
class ParallelStateMachine:
    var active_states: Array = []
    
    func update_states(delta: float) -> void:
        for state in active_states:
            state._update(delta)
```

## 🔧 故障排除

### 1. 常见问题

1. **状态卡住**
   - 检查转换条件
   - 验证状态退出逻辑

2. **性能问题**
   - 优化状态更新频率
   - 减少状态切换

### 2. 调试技巧

1. **状态日志**
   - 记录状态变化
   - 监控状态时间

2. **可视化调试**
   - 显示当前状态
   - 可视化状态转换

## 📚 参考资源

- [状态机设计模式](https://gameprogrammingpatterns.com/state.html)
- [Godot 状态机示例](https://docs.godotengine.org/en/stable/tutorials/misc/state_design_pattern.html)
- [游戏编程模式](https://gameprogrammingpatterns.com/)
