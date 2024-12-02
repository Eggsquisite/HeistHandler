extends Node2D

@onready var sound: AudioStreamPlayer2D = $Sound


var _is_game_over: bool = false
var _is_level_complete: bool = false
var _total_loot: int = 0

@export_group("Loot Rank Percent")
@export var loot_three_star: float = 80
@export var loot_two_star: float = 50
@export var loot_one_star: float = 30

@export_group("Time Rank in Seconds")
@export var time_three_star: float = 60
@export var time_two_star: float = 90
@export var time_one_star: float = 120



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_is_game_over = false
	_is_level_complete = false
	get_total_loot()
	SignalManager.on_level_started.emit(_total_loot)
	
	SignalManager.on_game_over.connect(game_over)
	SignalManager.on_level_complete.connect(level_complete)
	SignalManager.on_score_end.connect(calculate_rank)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart") and _is_game_over:
		GameManager.reset_level()
	
	if Input.is_action_just_pressed("lockpick") and _is_level_complete:
		GameManager.load_next_level_scene()
	
	if Input.is_action_just_pressed("restart") and _is_level_complete:
		GameManager.reset_level()


func get_total_loot() -> int:
	for l in get_tree().get_nodes_in_group("chest"):
		_total_loot += l.get_loot_amt()
	
	for l in get_tree().get_nodes_in_group("loot"):
		_total_loot += l.get_loot_amt()
	return _total_loot


func calculate_rank(loot: int, time: float, _lvl: String) -> void:
	# Will not implement time for 1.0
	var tmp_rank: int
	if loot >= _total_loot * loot_three_star / 100:
		if time <= time_three_star:
			tmp_rank = 3
		elif time <= time_two_star:
			tmp_rank = 2
		elif time <= time_two_star:
			tmp_rank = 1
	elif loot >= _total_loot * loot_two_star / 100:
		if time <= time_two_star:
			tmp_rank = 2
		elif time <= time_two_star:
			tmp_rank = 1
		elif time > time_one_star:
			tmp_rank = 0
	elif loot >= _total_loot * loot_one_star / 100:
		if time <= time_one_star:
			tmp_rank = 1
		elif time > time_one_star:
			tmp_rank = 0
	else:
		tmp_rank = 0
	SignalManager.on_rank_set.emit(tmp_rank)


func game_over() -> void:
	_is_game_over = true


func level_complete() -> void:
	_is_level_complete = true
	SoundManager.play_clip(sound, SoundManager.SOUND_LVL_END)
