extends Window

@onready var save_game_btn = $MarginContainer/VBoxContainer/SaveGame
@onready var load_game_btn = $MarginContainer/VBoxContainer/LoadGame
@onready var settings_btn = $MarginContainer/VBoxContainer/Settings
@onready var exit_level_btn = $MarginContainer/VBoxContainer/ExitLevel
@onready var exit_game_btn = $MarginContainer/VBoxContainer/ExitGame

var save_load_panel_scene = preload("res://source/UI/save_load_panel.tscn")
var save_load_panel = null

func _ready() -> void:
	hide()
	visible = false
	# 设置窗口初始位置
	position = (DisplayServer.window_get_size() - size) / 2
	
	# 连接事件
	CoreSystem.event_bus.subscribe(GameEvents.GameFlowEvent.GAME_PAUSED, _on_game_paused)
	CoreSystem.event_bus.subscribe(GameEvents.GameFlowEvent.GAME_RESUMED, _on_game_resumed)

func _exit_tree() -> void:
	CoreSystem.event_bus.unsubscribe(GameEvents.GameFlowEvent.GAME_PAUSED, _on_game_paused)
	CoreSystem.event_bus.unsubscribe(GameEvents.GameFlowEvent.GAME_RESUMED, _on_game_resumed)

func _on_game_paused() -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _on_game_resumed() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_close_requested() -> void:
	GameEvents.GameFlowEvent.push_game_resumed()

func _on_save_game_pressed() -> void:
	create_save_load_panel(save_load_panel_scene.instantiate().Mode.SAVE)

func _on_load_game_pressed() -> void:
	create_save_load_panel(save_load_panel_scene.instantiate().Mode.LOAD)

func _on_settings_pressed() -> void:
	# TODO: 打开设置面板
	CoreSystem.logger.info("Settings button pressed")

func _on_exit_level_pressed() -> void:
	GameEvents.GameFlowEvent.push_exit_level()
	hide()

func _on_exit_game_pressed() -> void:
	GameEvents.GameFlowEvent.push_exit_game()

# 创建并显示存档/加载面板
func create_save_load_panel(mode) -> void:
	# 如果已经存在存档面板，则移除
	if save_load_panel:
		save_load_panel.queue_free()
	
	save_load_panel = save_load_panel_scene.instantiate()
	add_child(save_load_panel)
	
	# 设置面板模式
	save_load_panel.set_mode(mode)
	
	# 连接信号
	save_load_panel.save_selected.connect(_on_save_selected)
	save_load_panel.save_created.connect(_on_save_created)
	save_load_panel.back_requested.connect(_on_save_panel_back_requested)
	
	# 调整面板位置
	save_load_panel.position = Vector2((size.x - save_load_panel.size.x) / 2, 
							  (size.y - save_load_panel.size.y) / 2)

# 处理选择存档事件
func _on_save_selected(save_index: int) -> void:
	if save_load_panel.get("_mode") == save_load_panel_scene.instantiate().Mode.SAVE:
		GameInstance.save_game(save_index)
		CoreSystem.logger.info("Game saved to slot: " + str(save_index))
	else:
		GameInstance.load_game(save_index)
		CoreSystem.logger.info("Game loaded from slot: " + str(save_index))
		hide()
		GameEvents.GameFlowEvent.push_game_resumed()

# 处理创建新存档事件
func _on_save_created(save_name: String) -> void:
	var next_index = SaveManager.get_next_save_index()
	GameInstance.save_game(next_index, save_name)
	CoreSystem.logger.info("New save created: " + save_name + " (slot: " + str(next_index) + ")")
	save_load_panel.refresh_saves()

# 处理存档面板返回事件
func _on_save_panel_back_requested() -> void:
	if save_load_panel:
		save_load_panel.queue_free()
		save_load_panel = null
