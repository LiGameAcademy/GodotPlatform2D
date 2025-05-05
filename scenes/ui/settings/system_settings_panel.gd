extends Container

## 系统设置面板

# 节点引用 (如果需要直接引用子节点，可以在这里添加)
# @onready var description_label: Label = $Description 

# 系统引用
@onready var config_manager: CoreSystem.ConfigManager = CoreSystem.config_manager

# 预制场景
const LanguageOption = preload(ResourcePaths.UI.LANGUAGE_OPTION)

func _ready() -> void:
	# 清除现有的动态添加的设置项 (如果需要重置的话)
	# 这确保在场景树中重新添加节点时不会重复
	# 但在此场景中，如果 LanguageOption 是唯一动态添加的，
	# 并且 _ready 只运行一次，可能不需要清除。
	# 暂时保留注释，以备后用。
	# for child in get_children():
	#	 if child.name == "LanguageOptionInstance": # 给实例一个名字以便查找
	#		 child.queue_free()
			
	# 添加语言选择
	var language_option = LanguageOption.instantiate()
	language_option.name = "LanguageOptionInstance" # 给实例一个名字
	add_child(language_option)
	language_option.language_changed.connect(_on_language_changed)
	
	# 如果需要加载当前语言设置，可以在这里添加
	# 例如: language_option.set_current_language(config_manager.get_value("system", "locale", TranslationServer.get_locale()))


func _on_language_changed(locale: String) -> void:
	TranslationServer.set_locale(locale)
	config_manager.set_value("system", "locale", locale)
	# 注意：保存配置的操作现在由 SettingsDialog 的保存按钮统一处理
	# config_manager.save_config() # 不应在此处单独保存 
