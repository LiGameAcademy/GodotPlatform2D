extends Button
# 存档项界面组件
# 用于在存档列表中显示单个存档信息

@onready var save_name_label: Label = $HBoxContainer/SaveName
@onready var level_label: Label = $HBoxContainer/Level
@onready var date_label: Label = $HBoxContainer/Date
@onready var delete_button: Button = $HBoxContainer/DeleteButton

signal delete_requested(save_index: int)

var save_index := -1

func _ready() -> void:
	delete_button.pressed.connect(_on_delete_pressed)
	# 确保按下删除按钮时不会同时触发项目按钮的pressed信号
	delete_button.mouse_entered.connect(func(): set_mouse_filter(MOUSE_FILTER_IGNORE))
	delete_button.mouse_exited.connect(func(): set_mouse_filter(MOUSE_FILTER_STOP))

# 设置存档项数据
func setup(save_info: Dictionary) -> void:
	save_index = save_info.get("index", -1)
	save_name_label.text = save_info.get("name", "未命名存档")
	level_label.text = "关卡: " + str(save_info.get("level", 0))
	date_label.text = save_info.get("save_date", "")

# 处理删除按钮点击
func _on_delete_pressed() -> void:
	# 阻止事件传播
	get_viewport().set_input_as_handled()
	
	# 创建确认对话框
	var dialog = ConfirmationDialog.new()
	dialog.title = "删除存档"
	dialog.dialog_text = "确定要删除此存档吗？"
	dialog.confirmed.connect(func(): _confirm_delete())
	
	# 设置对话框样式
	dialog.min_size = Vector2(250, 100)
	dialog.ok_button_text = "删除"
	dialog.cancel_button_text = "取消"
	
	# 添加到场景并显示
	add_child(dialog)
	dialog.popup_centered()

# 确认删除
func _confirm_delete() -> void:
	if save_index >= 0:
		emit_signal("delete_requested", save_index)
