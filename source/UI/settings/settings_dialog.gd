extends Window

## 设置弹窗

# 节点引用
@onready var settings_tabs: TabContainer = %SettingsTabs
@onready var system_settings: VBoxContainer = %SystemSettings
@onready var input_settings: VBoxContainer = %InputSettings
@onready var audio_settings: VBoxContainer = %AudioSettings
@onready var graphics_settings: VBoxContainer = %GraphicsSettings
@onready var save_button: Button = %SaveButton
@onready var reset_button: Button = %ResetButton

# 系统引用
var config_manager: Node
var input_manager: Node

# 预制场景
const InputMappingItem = preload(ResourcePaths.UI.INPUT_MAPPING_ITEM)
const VolumeSliderItem = preload(ResourcePaths.UI.VOLUME_SLIDER_ITEM)
const GraphicsOptionItem = preload(ResourcePaths.UI.GRAPHICS_OPTION_ITEM)
const LanguageOption = preload(ResourcePaths.UI.LANGUAGE_OPTION)

# 音频设置配置项
const VOLUME_SETTINGS = {
	"SETTINGS_MASTER_VOLUME": "audio/master_volume",
	"SETTINGS_MUSIC_VOLUME": "audio/music_volume",
	"SETTINGS_SFX_VOLUME": "audio/sfx_volume"
}

# 图形设置配置项
const GRAPHICS_SETTINGS = {
	"SETTINGS_FULLSCREEN": {"key": "graphics/fullscreen", "default": false},
	"SETTINGS_VSYNC": {"key": "graphics/vsync", "default": true},
	"SETTINGS_SHOW_FPS": {"key": "graphics/show_fps", "default": false}
}

# 输入映射UI缓存
var _input_mapping_ui: Dictionary = {}
# 当前正在等待输入的动作
var _current_remapping_action: String = ""
# 是否正在等待输入
var _waiting_for_input: bool = false

func _ready() -> void:
	config_manager = CoreSystem.config_manager
	input_manager = CoreSystem.input_manager
	
	# 连接信号
	config_manager.config_loaded.connect(_on_config_loaded)
	input_manager.input_remapped.connect(_on_input_remapped)
	save_button.pressed.connect(_on_save_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	
	# 设置标签文本
	title = tr("SETTINGS_TITLE")
	settings_tabs.set_tab_title(0, tr("SETTINGS_SYSTEM"))
	settings_tabs.set_tab_title(1, tr("SETTINGS_INPUT"))
	settings_tabs.set_tab_title(2, tr("SETTINGS_AUDIO"))
	settings_tabs.set_tab_title(3, tr("SETTINGS_GRAPHICS"))
	save_button.text = tr("SETTINGS_SAVE")
	reset_button.text = tr("SETTINGS_RESET")
	
	# 初始化设置UI
	_init_system_settings()
	_init_input_settings()
	_init_audio_settings()
	_init_graphics_settings()
	
	# 加载当前配置
	_load_current_settings()

func _init_system_settings() -> void:
	# 清除现有的系统设置
	for child in system_settings.get_children():
		if child.name != "Description" and child.name != "HSeparator":
			child.queue_free()
	
	# 添加语言选择
	var language_option = LanguageOption.instantiate()
	system_settings.add_child(language_option)
	language_option.language_changed.connect(_on_language_changed)

func _init_input_settings() -> void:
	# 清除现有的映射UI
	for child in input_settings.get_children():
		if child.name != "Description" and child.name != "HSeparator":
			child.queue_free()
	
	# 创建输入映射UI
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):  # 只显示UI相关的输入
			var item = InputMappingItem.instantiate()
			input_settings.add_child(item)
			
			# 设置动作名称
			item.set_action_name(_get_display_name(action))
			
			# 设置按键文本
			item.set_button_text(_get_action_key_string(action))
			
			# 连接信号
			item.remap_requested.connect(_on_remap_button_pressed.bind(action))
			
			# 缓存UI引用
			_input_mapping_ui[action] = item

func _init_audio_settings() -> void:
	# 清除现有的音量控件
	for child in audio_settings.get_children():
		if child.name != "Description" and child.name != "HSeparator":
			child.queue_free()
	
	# 添加音量滑块
	for key in VOLUME_SETTINGS:
		var item = VolumeSliderItem.instantiate()
		audio_settings.add_child(item)
		
		# 设置标签文本
		item.set_label_text(tr(key))
		
		# 设置滑块值和回调
		var config_key = VOLUME_SETTINGS[key]
		var section = config_key.split("/")[0]
		var key_name = config_key.split("/")[1]
		var config = config_manager.get_section(section)
		item.set_value(config.get(key_name, 100) if config else 100)
		
		# 当滑块值改变时更新配置
		item.value_changed.connect(
			func(value): 
				var cfg = config_manager.get_section(section) if config_manager.has_section(section) else {}
				cfg[key_name] = value
				config_manager.set_section(section, cfg)
		)

func _init_graphics_settings() -> void:
	# 清除现有的图形选项
	for child in graphics_settings.get_children():
		if child.name != "Description" and child.name != "HSeparator":
			child.queue_free()
	
	# 添加图形设置选项
	for key in GRAPHICS_SETTINGS:
		var item = GraphicsOptionItem.instantiate()
		graphics_settings.add_child(item)
		
		# 设置标签文本
		item.set_label_text(tr(key))
		
		# 设置复选框状态和回调
		var setting = GRAPHICS_SETTINGS[key]
		var config_key = setting["key"]
		var default_value = setting["default"]
		var section = config_key.split("/")[0]
		var key_name = config_key.split("/")[1]
		var config = config_manager.get_section(section)
		item.set_pressed(config.get(key_name, default_value) if config else default_value)
		
		# 当复选框状态改变时更新配置
		item.toggled.connect(
			func(pressed): 
				var cfg = config_manager.get_section(section) if config_manager.has_section(section) else {}
				cfg[key_name] = pressed
				config_manager.set_section(section, cfg)
		)

func _get_display_name(action: String) -> String:
	# 将动作名称转换为显示名称
	return action.substr(3).capitalize().replace("_", " ")

func _get_action_key_string(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.is_empty():
		return tr("SETTINGS_NOT_SET")
	
	var event = events[0]
	if event is InputEventKey:
		return event.as_text()
	elif event is InputEventJoypadButton:
		return tr("SETTINGS_GAMEPAD") + str(event.button_index)
	
	return tr("SETTINGS_NOT_SET")

func _on_remap_button_pressed(action: String) -> void:
	if _waiting_for_input:
		return
	
	_current_remapping_action = action
	_waiting_for_input = true
	_input_mapping_ui[action].set_button_text(tr("SETTINGS_PRESS_KEY"))

func _on_input_remapped(action_name: String, events: Array[InputEvent]) -> void:
	if _input_mapping_ui.has(action_name):
		_input_mapping_ui[action_name].set_button_text(_get_action_key_string(action_name))

func _on_language_changed(locale: String) -> void:
	# 刷新所有文本
	_ready()

func _on_save_button_pressed() -> void:
	config_manager.save_config()
	hide()

func _on_reset_button_pressed() -> void:
	config_manager.reset_to_default()
	_load_current_settings()

func _load_current_settings() -> void:
	# 重新初始化所有设置
	_init_system_settings()
	_init_input_settings()
	_init_audio_settings()
	_init_graphics_settings()

func _on_config_loaded() -> void:
	_load_current_settings()

func _unhandled_input(event: InputEvent) -> void:
	if not _waiting_for_input:
		return
	
	if event is InputEventKey or event is InputEventJoypadButton:
		# 阻止事件继续传播
		get_viewport().set_input_as_handled()
		
		if event is InputEventKey and event.keycode == KEY_ESCAPE:
			# 取消重映射
			_waiting_for_input = false
			_input_mapping_ui[_current_remapping_action].set_button_text(_get_action_key_string(_current_remapping_action))
			return
		
		# 重映射输入
		input_manager.remap_action(_current_remapping_action, [event])
		_waiting_for_input = false
