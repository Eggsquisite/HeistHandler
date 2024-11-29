extends Node2D


var _is_game_over: bool = false
var _is_level_complete: bool = false
var _total_loot: int = 0

@export_group("Loot Rank Percent")
@export var three_star: float = 70
@export var two_star: float = 50
@export var one_star: float = 30


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_is_game_over = false
	_is_level_complete = false
	get_total_loot()
	print(_total_loot)
	SignalManager.on_level_started.emit()
	
	SignalManager.on_game_over.connect(game_over)
	SignalManager.on_level_complete.connect(level_complete)
	SignalManager.on_score_end.connect(calculate_rank)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("lockpick") and _is_game_over:
		GameManager.reset_level()
	
	if Input.is_action_just_pressed("lockpick") and _is_level_complete:
		GameManager.load_next_level_scene()
	
	if Input.is_action_just_pressed("lockpick"):
		SignalManager.on_level_complete.emit()


func get_total_loot() -> void:
	for l in get_tree().get_nodes_in_group("chest"):
		_total_loot += l.get_loot_amt()
	
	for l in get_tree().get_nodes_in_group("loot"):
		_total_loot += l.get_loot_amt()


func calculate_rank(loot: int, _time: float, _lvl: String) -> void:
	# Will not implement time for 1.0
	var tmp_rank: int
	if loot >= _total_loot * three_star / 100:
		tmp_rank = 3
	elif loot >= _total_loot * two_star / 100:
		tmp_rank = 2
	elif loot < _total_loot * two_star / 100:
		tmp_rank = 1
	SignalManager.on_rank_set.emit(tmp_rank, _total_loot)


func game_over() -> void:
	_is_game_over = true


func level_complete() -> void:
	_is_level_complete = true
