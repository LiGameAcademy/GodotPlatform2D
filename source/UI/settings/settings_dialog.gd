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
@onready var config_manager: CoreSystem.ConfigManager = CoreSystem.config_manager
@onready var input_manager: CoreSystem.InputManager = CoreSystem.input_manager

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
	# 连接信号
	config_manager.config_loaded.connect(_on_config_loaded)
	input_manager.remap_completed.connect(_on_input_remapped)
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
	#_init_system_settings()
	#_init_input_settings()
	#_init_audio_settings()
	#_init_graphics_settings()
	
	# 加载当前配置
	#_load_current_settings()

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
		if not action.begins_with("ui_"):  # 只显示游戏相关的输入
			var item = InputMappingItem.instantiate()
			input_settings.add_child(item)
			
			# 设置动作名称
			item.set_action_name(_get_display_name(action))
			
			# 设置按键文本
			item.set_button_text(_get_action_key_string(action))
			
			# 连接信号
			item.remap_button_pressed.connect(_on_remap_button_pressed.bind(action))
			
			# 缓存UI引用
			_input_mapping_ui[action] = item

func _init_audio_settings() -> void:
	# 清除现有的音量滑块
	for child in audio_settings.get_children():
		if child.name != "Description" and child.name != "HSeparator":
			child.queue_free()
	
	# 创建音量滑块
	for setting in VOLUME_SETTINGS:
		var item = VolumeSliderItem.instantiate()
		audio_settings.add_child(item)
		
		# 设置标签和配置键
		item.set_label(tr(setting))
		item.value_changed.connect(_on_volume_changed.bind(VOLUME_SETTINGS[setting]))

func _init_graphics_settings() -> void:
	# 清除现有的图形选项
	for child in graphics_settings.get_children():
		if child.name != "Description" and child.name != "HSeparator":
			child.queue_free()
	
	# 创建图形选项
	for setting in GRAPHICS_SETTINGS:
		var item = GraphicsOptionItem.instantiate()
		graphics_settings.add_child(item)
		
		# 设置标签和配置键
		item.set_label(tr(setting))
		item.toggled.connect(_on_graphics_option_toggled.bind(GRAPHICS_SETTINGS[setting].key))

func _input(event: InputEvent) -> void:
	if _waiting_for_input and event.is_pressed():
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
			_waiting_for_input = false
			
			# 更新输入映射
			if _current_remapping_action:
				var events = [event]
				InputMap.action_erase_events(_current_remapping_action)
				InputMap.action_add_event(_current_remapping_action, event)
				
				# 更新UI
				if _input_mapping_ui.has(_current_remapping_action):
					_input_mapping_ui[_current_remapping_action].set_button_text(_get_action_key_string(_current_remapping_action))
					_input_mapping_ui[_current_remapping_action].set_remapping(false)
				
				# 保存配置
				_save_input_settings()
				
				_current_remapping_action = ""

func _get_display_name(action: String) -> String:
	# 将动作名称转换为显示名称
	return tr("INPUT_" + action.to_upper())

func _get_action_key_string(action: String) -> String:
	# 获取动作的按键字符串
	var events = InputMap.action_get_events(action)
	if events.is_empty():
		return tr("KEY_NONE")
	
	var event = events[0]
	if event is InputEventKey:
		return event.as_text()
	elif event is InputEventMouseButton:
		return tr("KEY_MOUSE_BUTTON").format({"button": event.button_index})
	elif event is InputEventJoypadButton:
		return tr("KEY_JOY_BUTTON").format({"button": event.button_index})
	
	return tr("KEY_UNKNOWN")

func _load_current_settings() -> void:
	# 加载音频设置
	for setting in VOLUME_SETTINGS:
		var bus_idx = AudioServer.get_bus_index(VOLUME_SETTINGS[setting].split("/")[1])
		if bus_idx >= 0:
			var volume_db = AudioServer.get_bus_volume_db(bus_idx)
			for child in audio_settings.get_children():
				if child and child.get_label() == tr(setting):
					child.set_value(db_to_linear(volume_db))
	
	# 加载图形设置
	for setting in GRAPHICS_SETTINGS:
		var value = config_manager.get_value("graphics", setting, GRAPHICS_SETTINGS[setting].default)
		for child in graphics_settings.get_children():
			if child and child.get_label() == tr(setting):
				child.set_checked(value)

func _save_input_settings() -> void:
	var input_config = {}
	for action in InputMap.get_actions():
		if not action.begins_with("ui_"):
			var events = InputMap.action_get_events(action)
			if not events.is_empty():
				input_config[action] = events[0]
	
	config_manager.set_section("input", input_config)
	config_manager.save_config()

func _on_config_loaded() -> void:
	_load_current_settings()

func _on_input_remapped(action: String, event: InputEvent) -> void:
	if _input_mapping_ui.has(action):
		_input_mapping_ui[action].set_button_text(_get_action_key_string(action))

func _on_remap_button_pressed(action: String) -> void:
	if _waiting_for_input:
		return
	
	_waiting_for_input = true
	_current_remapping_action = action
	
	if _input_mapping_ui.has(action):
		_input_mapping_ui[action].set_remapping(true)

func _on_volume_changed(value: float, bus_name: String) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name.split("/")[1])
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_graphics_option_toggled(value: bool, setting_key: String) -> void:
	config_manager.set_value("graphics", setting_key, value)
	match setting_key:
		"fullscreen":
			if value:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		"graphics/vsync":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED)

func _on_save_button_pressed() -> void:
	config_manager.save_config()
	hide()

func _on_reset_button_pressed() -> void:
	config_manager.reset_config()
	_load_current_settings()

func _on_language_changed(locale: String) -> void:
	TranslationServer.set_locale(locale)
	config_manager.set_value("system", "locale", locale)
