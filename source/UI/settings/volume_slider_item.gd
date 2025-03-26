extends HBoxContainer

## 音量滑块控件

# 信号
signal value_changed(value: float)

# 节点引用
@onready var label: Label = $Label
@onready var slider: HSlider = $HSlider

func _ready() -> void:
	slider.value_changed.connect(_on_slider_value_changed)

## 设置标签文本
func set_label_text(text: String) -> void:
	label.text = text

## 设置滑块值
func set_value(value: float) -> void:
	slider.value = value

## 获取滑块值
func get_value() -> float:
	return slider.value

## 滑块值改变回调
func _on_slider_value_changed(value: float) -> void:
	value_changed.emit(value)
