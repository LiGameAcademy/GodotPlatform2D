extends Node

## 翻译加载器

# 翻译文件路径
const TRANSLATIONS_PATH = "res://source/localization/translations"
const TRANSLATION_FILES = [
	"common.csv",  # 通用翻译文件放在最前面
	"settings.csv"
]

# 默认语言
const DEFAULT_LOCALE = "zh"
# 支持的语言
const SUPPORTED_LOCALES = ["zh", "en"]

func _ready() -> void:
	# 从配置中读取语言设置
	var config = CoreSystem.config_manager.get_section("system")
	var locale = config.get("language", DEFAULT_LOCALE) if config else DEFAULT_LOCALE
	
	# 设置当前语言
	set_locale(locale)

## 设置当前语言
## [param locale] 语言代码
func set_locale(locale: String) -> void:
	if locale in SUPPORTED_LOCALES:
		TranslationServer.set_locale(locale)
		# 保存语言设置
		var config = CoreSystem.config_manager.get_section("system") if CoreSystem.config_manager.has_section("system") else {}
		config["language"] = locale
		CoreSystem.config_manager.set_section("system", config)

## 获取当前语言
## [return] 当前语言代码
func get_locale() -> String:
	return TranslationServer.get_locale()

## 获取支持的语言列表
## [return] 语言代码列表
func get_supported_locales() -> PackedStringArray:
	return SUPPORTED_LOCALES
