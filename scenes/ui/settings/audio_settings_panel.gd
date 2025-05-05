extends MarginContainer
class_name AudioSettingsPanel

## 音频设置面板

# 节点引用 (使用唯一名称)
@onready var description_label: Label = %Description
@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var master_mute_checkbutton: CheckButton = %MasterMuteCheckButton
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var music_mute_check_button: CheckButton = %MusicMuteCheckButton
@onready var sfx_mute_check_button: CheckButton = %SfxMuteCheckButton

# 系统引用
var settings_manager: SettingsManager = GameInstance.settings_manager
var _logger : CoreSystem.Logger = CoreSystem.logger

func _ready() -> void:
	# 加载并设置初始值
	_load_setting_to_slider(master_volume_slider, "audio", "master_volume_db")
	_load_setting_to_slider(music_volume_slider, "audio", "music_volume_db")
	_load_setting_to_slider(sfx_volume_slider, "audio", "sfx_volume_db")
	
	master_mute_checkbutton.button_pressed = settings_manager.get_setting("audio", "master_mute")
	music_mute_check_button.button_pressed = settings_manager.get_setting("audio", "music_mute")
	sfx_mute_check_button.button_pressed = settings_manager.get_setting("audio", "sfx_mute")

	# 连接信号
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	master_mute_checkbutton.toggled.connect(_on_master_mute_toggled)
	music_mute_check_button.toggled.connect(_on_music_mute_toggled)
	sfx_mute_check_button.toggled.connect(_on_sfx_mute_toggled)

# Helper function to load dB setting and apply to slider as linear value
func _load_setting_to_slider(slider: HSlider, category: String, key: String) -> void:
	if not slider:
		_logger.error("Slider is null, cannot load setting to slider.")
		return

	var volume_db = settings_manager.get_setting(category, key)
	slider.value = db_to_linear(float(volume_db))

## 音量改变回调
func _on_master_volume_changed(value: float) -> void:
	settings_manager.update_setting("audio", "master_volume_db", linear_to_db(value))

func _on_music_volume_changed(value: float) -> void:
	settings_manager.update_setting("audio", "music_volume_db", linear_to_db(value))

func _on_sfx_volume_changed(value: float) -> void:
	settings_manager.update_setting("audio", "sfx_volume_db", linear_to_db(value))

func _on_master_mute_toggled(button_pressed: bool) -> void:
	settings_manager.update_setting("audio", "master_mute", button_pressed)

func _on_music_mute_toggled(button_pressed: bool) -> void:
	settings_manager.update_setting("audio", "music_mute", button_pressed)

func _on_sfx_mute_toggled(button_pressed: bool) -> void:
	settings_manager.update_setting("audio", "sfx_mute", button_pressed)
