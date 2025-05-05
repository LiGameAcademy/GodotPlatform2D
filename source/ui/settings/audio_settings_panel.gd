extends VBoxContainer
class_name AudioSettingsPanel

## 音频设置面板


# 预制场景
const VolumeSliderItemScene = preload(ResourcePaths.UI.VOLUME_SLIDER_ITEM)

# 音频设置配置项 - 包含总线名称和默认分贝值
const VOLUME_SETTINGS = {
	"SETTINGS_MASTER_VOLUME": {"bus": "master", "default_db": 0.0},  # 主音量默认为 0dB (最大)
	"SETTINGS_MUSIC_VOLUME":  {"bus": "music",  "default_db": -6.0}, # 音乐默认为 -6dB
	"SETTINGS_SFX_VOLUME":    {"bus": "sfx",    "default_db": -3.0}  # 音效默认为 -3dB
}

# 节点引用 (可以按需添加子节点引用)
@onready var description_label: Label = $Description

# 系统引用
# 注意：这里不再直接引用 CoreSystem，
# 而是假设需要的功能（如图形设置中的 DisplayServer 或 Audio 设置中的 AudioServer）是全局可访问的。
# 如果需要 ConfigManager 来加载/保存独立设置（虽然通常由父级统一处理），则需要添加：
# @onready var config_manager: CoreSystem.ConfigManager = CoreSystem.config_manager

# 存储 VolumeSliderItem 实例的字典，用于加载值
var _volume_sliders: Dictionary = {}

func _ready() -> void:
	_init_audio_settings()
	_load_current_audio_settings()

## 初始化音频设置
func _init_audio_settings() -> void:
	for child in get_children():
		# 需要一种方式来识别这些动态添加的项，例如通过类名或组
		if child is VolumeSliderItem: # 假设 VolumeSliderItem 有 set_label 方法
			child.queue_free()

	_volume_sliders.clear()

	# 创建音量滑块
	for setting_label_key in VOLUME_SETTINGS:
		var bus_name = VOLUME_SETTINGS[setting_label_key]
		var item = VolumeSliderItemScene.instantiate()
		add_child(item)

		# 设置标签和连接信号
		item.set_label(tr(setting_label_key))
		item.value_changed.connect(_on_volume_changed.bind(bus_name))

		# 缓存引用以便加载值
		_volume_sliders[bus_name] = item

## 加载当前音频设置
func _load_current_audio_settings() -> void:
	# 加载音频设置
	await get_tree().process_frame # 等待一帧确保 AudioServer 可用
	for bus_name in _volume_sliders:
		var bus_idx = AudioServer.get_bus_index(bus_name)
		if bus_idx >= 0:
			var volume_db = AudioServer.get_bus_volume_db(bus_idx)
			var slider_item = _volume_sliders[bus_name]
			if slider_item:
				slider_item.set_value(db_to_linear(volume_db))

## 音量改变回调
func _on_volume_changed(value: float, bus_name: String) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
		# 音频设置通常即时生效，更改直接应用到 AudioServer
		# 保存到 config 文件通常由 SettingsDialog 的 Save 按钮触发

# 可选：添加一个方法供 SettingsDialog 调用以响应重置按钮
func reset_to_defaults() -> void:
	print("Resetting audio settings panel...")
	# 在这里实现将音量重置为默认值的逻辑
	# 例如，可以为每个总线定义默认值
	var default_volumes_db = {
		"master": 0.0, # 0 dB
		"music": -6.0, # -6 dB
		"sfx": -3.0   # -3 dB
	}
	for bus_name in _volume_sliders:
		if default_volumes_db.has(bus_name):
			var default_db = default_volumes_db[bus_name]
			var default_linear = db_to_linear(default_db)
			var bus_idx = AudioServer.get_bus_index(bus_name)
			if bus_idx >= 0:
				AudioServer.set_bus_volume_db(bus_idx, default_db)
				var slider_item = _volume_sliders[bus_name]
				if slider_item and slider_item.has_method("set_value_no_signal"):
					slider_item.set_value_no_signal(default_linear)
				elif slider_item and slider_item.has_method("set_value"):
					slider_item.set_value(default_linear)

# 可选：添加一个方法供 SettingsDialog 调用以保存设置（如果需要单独保存音频设置到 config）
# func save_settings() -> void:
#     if config_manager:
#         for bus_name in _volume_sliders:
#             var bus_idx = AudioServer.get_bus_index(bus_name)
#             if bus_idx >= 0:
#                 var volume_db = AudioServer.get_bus_volume_db(bus_idx)
#                 # 将 dB 值保存到 config，键名可能需要调整
#                 config_manager.set_value("audio", bus_name + "_volume_db", volume_db)
#     else:
#         print("ConfigManager not available in AudioSettingsPanel")
