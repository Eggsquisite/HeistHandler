extends Node

const SCORE_FILE: String = "user://HeistScores.json"
const MAX_SCORES = 10
const DEFAULT_SCORE = 0

var guards_alerted: int = 0
var alert_began: bool = false

var _level_selected: int = 1
var _level_scores: Dictionary = {}
var _loot: int = 0
var _time: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_guard_alert.connect(guard_alerted)
	SignalManager.on_guard_lost.connect(guard_lost)
	SignalManager.on_game_over.connect(game_over)
	SignalManager.on_loot_end.connect(set_scores_for_level)
	set_scores_for_level(5, 728, "1")


func set_level_selected(ls: int) -> void:
	_level_selected = ls


func get_level_selected() -> int:
	return _level_selected


func check_and_add(level: String) -> void:
	if _level_scores.has(level) == false:
		_level_scores[level][0] = DEFAULT_SCORE
		_level_scores[level][1] = DEFAULT_SCORE



func set_scores_for_level(loot: int, time: float, level: String) -> void:
	check_and_add(level)
	if _level_scores[level][0] < loot:
		_level_scores[level][0] = loot
	if _level_scores[level][1] > time:
		_level_scores[level][1] = time


func get_best_for_level(level: String) -> Array:
	check_and_add(level)
	return _level_scores[level]


func guard_alerted() -> void:
	if !alert_began:
		alert_began = true
		SignalManager.on_alert_start.emit() # On first alert status, start alarm 
	guards_alerted += 1


func guard_lost() -> void:
	guards_alerted -= 1
	if alert_began and guards_alerted == 0:
		SignalManager.on_alert_end.emit() # if no remaining guards alerted, end alarm


func game_over() -> void:
	for enemies in get_tree().get_nodes_in_group("enemy"):
		enemies.set_process(false)
		enemies.set_physics_process(false)
