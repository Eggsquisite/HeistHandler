extends Node

const SCORE_FILE: String = "user://HeistScores.json"
const MAIN = preload("res://scenes/main/main.tscn")
const TOTAL_LEVELS = 7
const SECRET_LEVELS = 3
const DEFAULT_LOOT = 0
const DEFAULT_TIME = 1000.0

var guards_alerted: int = 0
var alert_began: bool = false

var _level_scenes: Dictionary = {}
var _level_selected: int = 1
var _level_scores: Dictionary = {}
var _loot: int = 0
var _time: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for ln in range(1, TOTAL_LEVELS + 1):
		# _level_scenes[ln] = load("res://scenes/base_level/base_level.tscn")
		_level_scenes[ln] = load("res://scenes/base_level/level_%d.tscn" % ln)
	
	SignalManager.on_guard_alert.connect(guard_alerted)
	SignalManager.on_guard_lost.connect(guard_lost)
	SignalManager.on_game_over.connect(game_over)
	SignalManager.on_level_complete.connect(level_complete)
	SignalManager.on_score_end.connect(set_scores_for_level)
	set_scores_for_level(5, 728, "1")


func set_level_selected(ls: int) -> void:
	_level_selected = ls


func get_level_selected() -> int:
	return _level_selected


func check_and_add(level: String) -> void:
	var tmp = [DEFAULT_LOOT, DEFAULT_TIME]
	if _level_scores.has(level) == false:
		_level_scores[level] = tmp


func set_scores_for_level(loot: int, time: float, level: String) -> void:
	check_and_add(level)
	if _level_scores[level][0] < loot:
		_level_scores[level][0] = loot
	if _level_scores[level][1] > time:
		_level_scores[level][1] = time
	print(_level_scores[level])


func get_best_for_level(level: String) -> Array:
	check_and_add(level)
	return _level_scores[level]


func load_main_scene() -> void:
	_level_selected = 0
	get_tree().change_scene_to_packed(MAIN)


func load_next_level_scene() -> void:
	set_next_level()
	get_tree().change_scene_to_packed(_level_scenes[_level_selected])


func set_next_level() -> void:
	_level_selected += 1
	if _level_selected > TOTAL_LEVELS:
		_level_selected = 1
		# TODO create a final scene


func reset_level() -> void:
	get_tree().change_scene_to_packed(_level_scenes[_level_selected])


func guard_alerted() -> void:
	if !alert_began:
		alert_began = true
		SignalManager.on_alert_start.emit() # On first alert status, start alarm 
	guards_alerted += 1


func guard_lost() -> void:
	guards_alerted -= 1
	if alert_began and guards_alerted == 0:
		alert_began = false
		print("alert over")
		SignalManager.on_alert_end.emit() # if no remaining guards alerted, end alarm


func game_over() -> void:
	for enemies in get_tree().get_nodes_in_group("enemy"):
		enemies.level_end()


func level_complete() -> void:
	for enemies in get_tree().get_nodes_in_group("enemy"):
		enemies.level_end()
