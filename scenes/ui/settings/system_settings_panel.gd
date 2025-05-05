extends MarginContainer

## 系统设置面板

# 节点引用 (移除了 %)
@onready var language_option_instance: HBoxContainer = %LanguageOptionInstance
@onready var ui_scale_slider: HSlider = %UIScaleSlider
@onready var screen_shake_slider: HSlider = %ScreenShakeSlider
@onready var subtitles_check_button: CheckButton = %SubtitlesCheckButton
@onready var vibration_check_button: CheckButton = %VibrationCheckButton

# 系统引用
var settings_manager: SettingsManager = GameInstance.settings_manager
var _logger : CoreSystem.Logger = CoreSystem.logger

func _ready() -> void:
	# -- 初始化语言选项 --
	# LanguageOption 实例应该在它自己的 _ready 中初始化
	# 我们只需要连接它的信号
	if language_option_instance and language_option_instance.has_signal("language_changed"):
		language_option_instance.language_changed.connect(_on_language_option_language_changed)
	else:
		_logger.error("LanguageOptionInstance node not found or does not have 'language_changed' signal.")

	# -- 初始化其他设置 (使用 settings_manager 实例) --
	# UI 缩放
	ui_scale_slider.value = settings_manager.get_setting("system", "ui_scale")
	ui_scale_slider.value_changed.connect(_on_ui_scale_slider_value_changed)

	# 屏幕震动强度
	screen_shake_slider.value = settings_manager.get_setting("system", "screen_shake_intensity")
	screen_shake_slider.value_changed.connect(_on_screen_shake_slider_value_changed)

	# 字幕开关
	subtitles_check_button.button_pressed = settings_manager.get_setting("system", "subtitles_enabled")
	subtitles_check_button.toggled.connect(_on_subtitles_check_button_toggled)

	# 手柄震动开关
	vibration_check_button.button_pressed = settings_manager.get_setting("system", "vibration_enabled")
	vibration_check_button.toggled.connect(_on_vibration_check_button_toggled)

# -- 移除了旧的 _on_language_option_item_selected --

# 新的处理 LanguageOptionInstance 信号的回调
func _on_language_option_language_changed(locale: String) -> void:
	_logger.info("SystemSettingsPanel: Language changed signal received: %s" % locale)
	settings_manager.update_setting("system", "locale", locale)


func _on_ui_scale_slider_value_changed(value: float) -> void:
	settings_manager.update_setting("system", "ui_scale", value)


func _on_screen_shake_slider_value_changed(value: float) -> void:
	settings_manager.update_setting("system", "screen_shake_intensity", value)


func _on_subtitles_check_button_toggled(button_pressed: bool) -> void:
	settings_manager.update_setting("system", "subtitles_enabled", button_pressed)


func _on_vibration_check_button_toggled(button_pressed: bool) -> void:
	settings_manager.update_setting("system", "vibration_enabled", button_pressed)


# 注意：应用设置的逻辑仍在 SettingsManager 中。
