extends Node2D


var _is_game_over: bool = false
var _is_level_complete: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_is_game_over = false
	_is_level_complete = false
	SignalManager.on_game_over.connect(game_over)
	SignalManager.on_level_complete.connect(level_complete)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("lockpick"):
		GameManager.reset_level()
	
	if Input.is_action_just_pressed("lockpick"):
		GameManager.load_next_level_scene()
	


func game_over() -> void:
	_is_game_over = true


func level_complete() -> void:
	_is_level_complete = true
