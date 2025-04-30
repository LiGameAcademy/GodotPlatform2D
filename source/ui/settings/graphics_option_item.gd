extends HBoxContainer

## 图形选项控件

# 信号
signal toggled(pressed: bool)

# 节点引用
@onready var label: Label = $Label
@onready var checkbox: CheckBox = $CheckBox

func _ready() -> void:
	checkbox.toggled.connect(_on_checkbox_toggled)

## 设置标签文本
func set_label_text(text: String) -> void:
	label.text = text

## 设置复选框状态
func set_pressed(pressed: bool) -> void:
	checkbox.button_pressed = pressed

## 获取复选框状态
func get_pressed() -> bool:
	return checkbox.button_pressed

## 复选框状态改变回调
func _on_checkbox_toggled(pressed: bool) -> void:
	toggled.emit(pressed)
