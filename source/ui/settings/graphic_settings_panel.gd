extends VBoxContainer

# 预设分辨率列表[显示字符串， Vectori值]
const PREDEFINED_RESOLUTIONS : Dictionary = {
    "1280 x 720": Vector2i(1280, 720),
    "1366 x 768": Vector2i(1366, 768),
    "1600 x 900": Vector2i(1600, 900),
    "1920 x 1080": Vector2i(1920, 1080),
    "2560 x 1440": Vector2i(2560, 1440)
}

@onready var resolution_option_button: OptionButton = %ResolutionOptionButton

func _ready() -> void:
    _init_resolution_dropdown()
    GameInstance.settings_manager.setting_changed.connect(_on_settings_changed)


## 初始化分辨率下拉列表
func _init_resolution_dropdown() -> void:
    # 清空选项
    resolution_option_button.clear()
    var index := 0

    # 获取当前设置并选中的对应选项
    var current_resolution = GameInstance.settings_manager.get_current_resolution()
    var selected_index := -1
    for resolution_name in PREDEFINED_RESOLUTIONS:
        resolution_option_button.add_item(resolution_name, index)

        if current_resolution == PREDEFINED_RESOLUTIONS[resolution_name]:
            selected_index = index
            break

        index += 1

    if selected_index != -1:
        resolution_option_button.select(selected_index)
    else:
        # 如果当前设置的分辨率不在预设列表中，默认不选
        if resolution_option_button.item_count > 0:
            resolution_option_button.selected = -1

    resolution_option_button.item_selected.connect(_on_resolution_selected)

## 当分辨率下拉列表选中时
func _on_resolution_selected(index: int) -> void:
    var resolution_name : String = resolution_option_button.get_item_text(index)
    var resolution : Vector2i = PREDEFINED_RESOLUTIONS[resolution_name]
    GameInstance.settings_manager.update_setting("graphics", "resolution_width", resolution.x)
    GameInstance.settings_manager.update_setting("graphics", "resolution_height", resolution.y)

## 当设置改变时
func _on_settings_changed(category: String, key: String, value: Variant) -> void:
    if category != "graphics":
        return
    
    if key == "resolution_width" or key == "resolution_height":
        # 分辨率设置被外部更改 (例如重置)
        var current_width = GameInstance.settings_manager.get_setting("graphics", "resolution_width")
        var current_height = GameInstance.settings_manager.get_setting("graphics", "resolution_height")
        var current_resolution = Vector2i(current_width, current_height)

        var selected_index = -1
        for i in range(PREDEFINED_RESOLUTIONS.size()):
            if PREDEFINED_RESOLUTIONS[i][1] == current_resolution:
                selected_index = i
                break

        # 更新 OptionButton 的选中项，不触发信号
        if selected_index != -1:
            # 检查当前选中的是否已经是目标索引，避免不必要的 UI 更新
            if resolution_option_button.selected != selected_index:
                resolution_option_button.select(selected_index)
        else:
            # 如果重置后的分辨率不在列表中，处理方式同 _ready
            if resolution_option_button.selected != 0: # 假设默认重置到第一个
                if resolution_option_button.item_count > 0:
                    resolution_option_button.select(0)
                else:
                    resolution_option_button.selected = -1

    # 可以添加对其他设置项更改的处理，以更新对应的 UI 控件
    # elif key == "brightness":
    #     var brightness_value = settings_manager.get_setting("graphics", "brightness")
    #     brightness_slider.value = brightness_value # 假设有亮度滑块
    # ...等等