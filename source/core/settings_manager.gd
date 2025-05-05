extends Node
class_name SettingsManager

## 设置管理器 
## SettingsManager (逻辑层): 负责所有与设置相关的数据和行为。它知道：
## 有哪些设置项 (系统、输入、音频、图形等)。
## 每个设置项的当前值是多少。
## 每个设置项的默认值是多少。
## 如何从 ConfigManager 加载/保存设置。
## 如何将设置应用到游戏引擎（例如调用 AudioServer, DisplayServer, InputMap, TranslationServer）。
## 如何将所有设置重置为默认值。

signal settings_applied # Emitted after settings are loaded and applied initially
signal setting_changed(category, key, value) # Emitted when a single setting is updated

# --- Configuration ---

const DEFAULT_SETTINGS = {
	"system": {
		"locale": "en", # 默认语言环境 (e.g., "en", "zh_CN")
		"ui_scale": 1.0,   # UI 缩放比例 (float)
		"subtitles_enabled": true,       # 字幕开关 (bool)
		"screen_shake_intensity": 1.0, # 屏幕震动强度 (float, 0.0 to 1.0)
		"vibration_enabled": true        # 手柄震动开关 (bool)
	},
	"audio": {
		# 总线名称和默认分贝值
		"master_volume_db": 0.0,
		"music_volume_db": -6.0,
		"sfx_volume_db": -3.0,
		"master_mute": false # 主静音 (bool)
	},
	"graphics": {
		"fullscreen": false,         # 全屏模式 (bool)
		"vsync": true,             # 垂直同步 (bool)
		"show_fps": false,         # 显示 FPS (bool)
		# 分辨率（注意：这只是默认值，实际应用可能需要获取支持的分辨率列表）
		"resolution_width": 1280,  # 默认宽度 (int)
		"resolution_height": 720, # 默认高度 (int)
		"brightness": 1.0          # 亮度 (float, 0.0 to 2.0, default 1.0)
	},
	# 注意：Input 设置仍然由 InputMap 单独处理加载/保存逻辑
}

# --- Dependencies ---

@onready var config_manager: CoreSystem.ConfigManager = CoreSystem.config_manager

# --- State ---

# Holds the current settings values loaded from config or defaults
var _current_settings: Dictionary = {}

var _logger : CoreSystem.Logger = CoreSystem.logger

# --- Lifecycle ---

func _ready() -> void:
	# Load settings immediately when the manager is ready
	load_settings()
	# Apply loaded settings to the engine
	apply_all_settings()
	# Optional: Emit a signal indicating initial settings are applied
	settings_applied.emit()

# --- Core Methods ---

## Loads settings from ConfigManager, falling back to defaults.
func load_settings() -> void:
	print("SettingsManager: Loading settings...")
	_current_settings = {} # Start fresh

	for category in DEFAULT_SETTINGS:
		_current_settings[category] = {}
		for key in DEFAULT_SETTINGS[category]:
			var default_value = DEFAULT_SETTINGS[category][key]
			# Load from config, using default if not found
			_current_settings[category][key] = config_manager.get_value(category, key, default_value)

	# Special handling for InputMap: Load from "input" section of config
	_load_input_map_from_config()
	print("SettingsManager: Settings loaded.")

## Applies all currently loaded settings to the engine.
func apply_all_settings() -> void:
	print("SettingsManager: Applying all settings...")
	for category in _current_settings:
		# Input is applied during load/reset, skip here
		if category == "input": continue
		for key in _current_settings[category]:
			_apply_setting(category, key, _current_settings[category][key])
	print("SettingsManager: All settings applied.")

## Saves the current settings state (excluding InputMap) to ConfigManager.
## Also triggers saving the InputMap separately.
func save_settings() -> void:
	print("SettingsManager: Saving settings...")
	for category in _current_settings:
		# InputMap saved separately
		if category == "input": continue
		for key in _current_settings[category]:
			config_manager.set_value(category, key, _current_settings[category][key])

	# Special handling for InputMap: Save current InputMap to config
	_save_input_map_to_config()

	config_manager.save_config()
	print("SettingsManager: Settings saved.")

## Resets all settings to their default values, applies them, and saves.
func reset_settings() -> void:
	print("SettingsManager: Resetting settings to defaults...")
	# Reset non-input settings based on DEFAULT_SETTINGS
	_current_settings = {}
	for category in DEFAULT_SETTINGS:
		_current_settings[category] = DEFAULT_SETTINGS[category].duplicate(true) # Deep copy

	# Apply the reset non-input settings
	apply_all_settings()

	# Special handling for InputMap: Reset to project defaults
	InputMap.load_from_project_settings()
	print("InputMap reset to project settings.")

	# Save the reset state immediately
	save_settings()
	print("SettingsManager: Settings reset and saved.")

## Updates a single setting, applies it, and potentially marks for saving.
func update_setting(category: String, key: String, value) -> void:
	if not _current_settings.has(category) or not _current_settings[category].has(key):
		_logger.error("SettingsManager: Attempted to update unknown setting '%s/%s'" % [category, key])
		return

	if _current_settings[category][key] != value:
		_logger.info("SettingsManager: Updating setting '%s/%s' to %s" % [category, key, str(value)])
		_current_settings[category][key] = value
		_apply_setting(category, key, value)
		setting_changed.emit(category, key, value)
		# Note: Changes are applied immediately but only saved when save_settings() is called.


## Retrieves the current value of a specific setting.
func get_setting(category: String, key: String):
	if _current_settings.has(category) and _current_settings[category].has(key):
		return _current_settings[category][key]
	else:
		_logger.error("SettingsManager: Attempted to get unknown setting '%s/%s'" % [category, key])
		# Fallback to default if defined, otherwise null
		return DEFAULT_SETTINGS.get(category, {}).get(key, null)


## Updates a specific action in the InputMap. Called by the Input Settings UI.
func update_input_action(action: String, event: InputEvent) -> void:
	if not InputMap.has_action(action):
		_logger.error("SettingsManager: Attempted to update unknown input action '%s'" % action)
		return

	print("SettingsManager: Remapping action '%s' to event: %s" % [action, event.as_text()])
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	# Emit signal or rely on UI to know? Let's emit.
	setting_changed.emit("input", action, event) # Value is the new event
	# InputMap changes are applied immediately, saved on save_settings()

## 获取当前分辨率
func get_current_resolution() -> Vector2i:
	return Vector2i(_current_settings.graphics.resolution_width, _current_settings.graphics.resolution_height)

# --- Internal Helpers ---

## Applies a single setting based on its category and key.
func _apply_setting(category: String, key: String, value) -> void:
	# print("Applying %s/%s = %s" % [category, key, str(value)]) # Verbose logging
	match category:
		"system":
			match key:
				"locale":
					if TranslationServer.get_locale() != value:
						print("Applying locale: %s" % value)
						TranslationServer.set_locale(value)
				"ui_scale":
					print("Setting 'ui_scale': %s (application logic handled by UI layer)" % str(value))
				"subtitles_enabled":
					print("Setting 'subtitles_enabled': %s (application logic handled by subtitles system)" % str(value))
				"screen_shake_intensity":
					print("Setting 'screen_shake_intensity': %s (application logic handled by camera/effect system)" % str(value))
				"vibration_enabled":
					print("Setting 'vibration_enabled': %s (application logic handled by input processing/player feedback)" % str(value))
		"audio":
			var bus_name = ""
			var is_mute_key = false
			if key.ends_with("_volume_db"):
				bus_name = key.replace("_volume_db", "")
			elif key.ends_with("_mute"):
				bus_name = key.replace("_mute", "")
				is_mute_key = true
			else:
				printerr("SettingsManager: Unknown audio key '%s'" % key)
				return

			var bus_idx = AudioServer.get_bus_index(bus_name)
			if bus_idx >= 0:
				if is_mute_key:
					var target_mute = bool(value)
					if AudioServer.is_bus_mute(bus_idx) != target_mute:
						print("Applying audio %s mute: %s" % [bus_name, str(target_mute)])
						AudioServer.set_bus_mute(bus_idx, target_mute)
				else: # 是音量键
					var target_db = float(value)
					if not is_equal_approx(AudioServer.get_bus_volume_db(bus_idx), target_db):
						print("Applying audio %s volume: %s dB" % [bus_name, str(target_db)])
						AudioServer.set_bus_volume_db(bus_idx, target_db)
			else:
				printerr("SettingsManager: Audio bus '%s' not found for setting '%s'." % [bus_name, key])
		"graphics":
			match key:
				"fullscreen":
					var current_mode = DisplayServer.window_get_mode()
					var target_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED
					if current_mode != target_mode:
						print("Applying fullscreen: %s" % str(value))
						DisplayServer.window_set_mode(target_mode)
				"vsync":
					var current_mode = DisplayServer.window_get_vsync_mode()
					var target_mode = DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED
					if current_mode != target_mode:
						print("Applying vsync: %s" % str(value))
						DisplayServer.window_set_vsync_mode(target_mode)
				"show_fps":
					print("Setting 'show_fps': %s (application logic handled by FPS display UI)" % str(value))
				"resolution_width", "resolution_height":
					# 延迟一帧应用分辨率，避免在同一帧内处理模式切换和大小调整可能引发的问题
					call_deferred("_apply_resolution")
				"brightness":
					# 亮度通常需要调整 WorldEnvironment。
					# SettingsManager 不直接应用，而是依赖其他系统监听 setting_changed 信号。
					print("Setting 'brightness': %s (application logic needs access to WorldEnvironment)" % str(value))

## 应用分辨率 (延迟调用)
func _apply_resolution() -> void:
	# 确保在 graphics 类别下有这两个键
	if not _current_settings.has("graphics") or \
	   not _current_settings.graphics.has("resolution_width") or \
	   not _current_settings.graphics.has("resolution_height"):
		printerr("SettingsManager: Cannot apply resolution, missing width or height setting.")
		return

	var new_width = int(_current_settings.graphics.resolution_width)
	var new_height = int(_current_settings.graphics.resolution_height)
	var new_size = Vector2i(new_width, new_height)

	# 只有在窗口模式下才尝试应用分辨率更改
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		# 检查当前尺寸是否不同，避免不必要的调用
		if DisplayServer.window_get_size() != new_size:
			print("Applying resolution: %s" % str(new_size))
			DisplayServer.window_set_size(new_size)
			# 应用后尝试将窗口居中
			# 使用 call_deferred 确保在窗口大小调整稳定后执行
			call_deferred("_center_window")
	else:
		print("In fullscreen mode, resolution managed by system, not manually setting window size.")

## 窗口居中 (延迟调用)
func _center_window() -> void:
	# 等待一小段时间确保窗口大小设置生效
	await get_tree().create_timer(0.1).timeout
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		var screen_size = DisplayServer.screen_get_size()
		var window_size = DisplayServer.window_get_size()
		var screen_pos = DisplayServer.screen_get_position()
		var window_pos = screen_pos + (screen_size - window_size) / 2
		DisplayServer.window_set_position(window_pos)
		print("Window centered.")


## Saves the current InputMap state to the "input" section of ConfigManager.
func _save_input_map_to_config() -> void:
	var input_section = {}
	for action in InputMap.get_actions():
		if action.begins_with("ui_"): continue # Skip UI actions

		var events = InputMap.action_get_events(action)
		if not events.is_empty():
			# WARNING: Saving raw InputEvent objects can be problematic.
			# They might contain runtime state or be complex objects.
			# Consider saving descriptors (keycode, button index, etc.) instead.
			# For now, saving the first event object for simplicity, matching previous approach.
			input_section[action] = events[0]

	config_manager.set_section("input", input_section)
	print("InputMap prepared for saving to config.")


## Loads the InputMap state from the "input" section of ConfigManager.
func _load_input_map_from_config() -> void:
	var input_section = config_manager.get_section("input")
	if input_section.is_empty():
		print("No input settings found in config, using project defaults.")
		InputMap.load_from_project_settings()
		return

	# Clear existing non-UI actions before loading from config
	for action in InputMap.get_actions():
		if not action.begins_with("ui_"):
			InputMap.action_erase_events(action)

	# Load actions from config
	for action in input_section:
		var event = input_section[action]
		if event is InputEvent: # Basic check
			if not InputMap.has_action(action):
				print("Warning: Config defines action '%s' not in project InputMap. Adding." % action)
				InputMap.add_action(action) # Add action if it doesn't exist
			InputMap.action_add_event(action, event)
		else:
			printerr("SettingsManager: Invalid event data found for action '%s' in config." % action)

	print("InputMap loaded from config.")




