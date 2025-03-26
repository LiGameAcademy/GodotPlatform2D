extends HBoxContainer

## 语言选择控件

# 信号
signal language_changed(locale: String)

# 节点引用
@onready var label: Label = $Label
@onready var option_button: OptionButton = $OptionButton

# 语言映射
const LANGUAGE_MAP = {
	"zh": "简体中文",
	"en": "English"
}

func _ready() -> void:
	# 设置标签文本
	label.text = tr("SETTINGS_LANGUAGE")
	
	# 清除选项
	option_button.clear()
	
	# 添加语言选项
	for locale in TranslationLoader.SUPPORTED_LOCALES:
		option_button.add_item(LANGUAGE_MAP[locale])
	
	# 设置当前语言
	var current_locale = TranslationLoader.get_locale()
	option_button.selected = TranslationLoader.SUPPORTED_LOCALES.find(current_locale)
	
	# 连接信号
	option_button.item_selected.connect(_on_language_selected)

## 语言选择回调
func _on_language_selected(index: int) -> void:
	var locale = TranslationLoader.SUPPORTED_LOCALES[index]
	TranslationLoader.set_locale(locale)
	language_changed.emit(locale)
