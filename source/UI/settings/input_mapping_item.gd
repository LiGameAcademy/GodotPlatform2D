extends HBoxContainer

## 输入映射控件

# 信号
signal remap_requested()

# 节点引用
@onready var label: Label = $ActionLabel
@onready var button: Button = $RemapButton

## 设置动作名称
func set_action_name(text: String) -> void:
	label.text = text

## 设置按键文本
func set_button_text(text: String) -> void:
	button.text = text

## 获取按键文本
func get_button_text() -> String:
	return button.text

## 按钮点击回调
func _on_remap_button_pressed() -> void:
	remap_requested.emit()
