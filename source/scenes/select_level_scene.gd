extends Control

const LEVEL_WIDGET := ResourcePaths.ScenePaths.LEVEL_WIDGET

@onready var grid_container : GridContainer = %GridContainer

var current_level_index := 0

func _ready() -> void:
	_init_level_widgets()


func _init_level_widgets() -> void:
	# 清除现有的关卡部件
	for child in grid_container.get_children():
		child.queue_free()
	
	# 创建新的关卡部件
	for i in range(GameInstance.level_manager.get_level_count()):
		var level_widget = LEVEL_WIDGET.instantiate()
		var level_index = i
		var is_unlocked = GameInstance.level_manager.is_level_unlocked(i)
		var is_completed = GameInstance.level_manager.is_level_completed(i)
		
		grid_container.add_child(level_widget)
		level_widget.set_level_info(level_index, is_unlocked, is_completed)
		
		if is_unlocked:
			level_widget.level_clicked.connect(_on_level_clicked.bind(i))

func _on_level_clicked(index: int) -> void:
	if not GameInstance.level_manager.is_level_unlocked(index):
		return
	GameEvents.LevelSelectEvent.push_level_selected(index)

func _on_btn_close_pressed() -> void:
	GameEvents.LevelSelectEvent.push_level_select_cancelled()
