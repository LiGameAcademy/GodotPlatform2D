extends Panel
# 存档读档面板
# 用于显示存档列表、创建新存档和加载存档

signal save_selected(save_index: int)
signal save_created(save_name: String)
signal back_requested

enum Mode { SAVE, LOAD }

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var save_list: VBoxContainer = $VBoxContainer/ScrollContainer/SaveList
@onready var info_label: Label = $VBoxContainer/ScrollContainer/SaveList/InfoLabel
@onready var new_save_button: Button = $VBoxContainer/ButtonsContainer/NewSaveButton
@onready var back_button: Button = $VBoxContainer/ButtonsContainer/BackButton

var save_item_scene := preload("res://source/UI/save_item.tscn")
var _mode: Mode = Mode.SAVE

func _ready() -> void:
	new_save_button.pressed.connect(_on_new_save_pressed)
	back_button.pressed.connect(_on_back_pressed)
	refresh_saves()

# 设置面板模式
func set_mode(mode: Mode) -> void:
	_mode = mode
	if _mode == Mode.SAVE:
		title_label.text = "保存游戏"
		new_save_button.show()
	else:
		title_label.text = "加载游戏"
		new_save_button.hide()
	
	refresh_saves()

# 刷新存档列表
func refresh_saves() -> void:
	# 移除现有的存档项
	for child in save_list.get_children():
		if child != info_label:
			child.queue_free()
	
	# 获取所有存档
	var saves = SaveManager.get_all_saves()
	
	# 显示或隐藏提示标签
	info_label.visible = saves.is_empty()
	
	# 创建存档项
	for save_info in saves:
		var save_item = save_item_scene.instantiate()
		save_list.add_child(save_item)
		save_item.setup(save_info)
		save_item.pressed.connect(func(): _on_save_item_pressed(save_info.index))
		save_item.delete_requested.connect(_on_delete_requested)

# 处理存档项点击
func _on_save_item_pressed(save_index: int) -> void:
	if _mode == Mode.SAVE:
		# 确认覆盖存档
		var dialog = ConfirmationDialog.new()
		dialog.title = "覆盖存档"
		dialog.dialog_text = "确定要覆盖此存档吗？"
		dialog.confirmed.connect(func(): emit_signal("save_selected", save_index))
		
		# 设置对话框样式
		dialog.min_size = Vector2(250, 100)
		
		# 添加到场景并显示
		add_child(dialog)
		dialog.popup_centered()
	else:
		# 直接加载存档
		emit_signal("save_selected", save_index)

# 处理新建存档按钮点击
func _on_new_save_pressed() -> void:
	# 创建输入对话框
	var dialog = LineEditDialog.new("新建存档", "请输入存档名称：")
	dialog.confirmed.connect(func(save_name): 
		if not save_name.is_empty():
			emit_signal("save_created", save_name)
	)
	
	# 添加到场景并显示
	add_child(dialog)
	dialog.popup_centered()

# 处理返回按钮点击
func _on_back_pressed() -> void:
	emit_signal("back_requested")

# 处理删除存档请求
func _on_delete_requested(save_index: int) -> void:
	SaveManager.delete_save(save_index)
	refresh_saves()

# 自定义输入对话框类
class LineEditDialog extends ConfirmationDialog:
	signal confirmed(text: String)
	
	var line_edit: LineEdit
	
	func _init(title_text: String, prompt_text: String) -> void:
		self.title = title_text
		
		# 创建内容容器
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 10)
		
		# 创建提示标签
		var label = Label.new()
		label.text = prompt_text
		vbox.add_child(label)
		
		# 创建输入框
		line_edit = LineEdit.new()
		line_edit.placeholder_text = "存档名称"
		line_edit.caret_blink = true
		line_edit.text = "存档 " + str(SaveManager.get_next_save_index())
		vbox.add_child(line_edit)
		
		# 设置对话框内容
		add_child(vbox)
		self.custom_minimun_size = Vector2(300, 150)
		
		# 连接信号
		confirmed.connect(func(): emit_signal("confirmed", line_edit.text))
