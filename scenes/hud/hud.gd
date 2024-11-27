extends Control

@onready var hb_hearts: HBoxContainer = $MC/HB/VB/HBHearts
@onready var loot_score: Label = $MC/HB/VB/LootScore
@onready var game_over_rect: ColorRect = $GameOverRect
@onready var level_complete_rect: ColorRect = $LevelCompleteRect
@onready var hb_stars: HBoxContainer = $LevelCompleteRect/VBLevelComplete/HBStars
@onready var minutes: Label = $MC/HB/TimerPanel/Minutes
@onready var seconds: Label = $MC/HB/TimerPanel/Seconds
@onready var msecs: Label = $MC/HB/TimerPanel/Msecs

var _hearts: Array
var _stars: Array
var _loot: int = 0
var _time: float = 0.0
var _time_start: float = 0.0
var _time_end: float = 0.0
var _time_elapsed: float = 0.0
var _minutes: int = 0
var _seconds: int = 0
var _msec: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	_hearts = hb_hearts.get_children()
	_stars = hb_stars.get_children()
	SignalManager.on_player_hit.connect(on_player_hit)
	SignalManager.on_level_started.connect(on_player_hit)
	SignalManager.on_level_started.connect(start_game_timer)
	SignalManager.on_level_complete.connect(stop_game_timer)
	SignalManager.on_loot_pickup.connect(update_loot_score)


func _process(delta: float) -> void:
	_time += delta
	_msec = fmod(_time, 1) * 100
	_seconds = fmod(_time, 60)
	_minutes = fmod(_time, 3600) / 60
	minutes.text = "%02d:" % _minutes
	seconds.text = "%02d" % _seconds
	msecs.text = ".%02d" % _msec


func stop_game_timer() -> void:
	set_process(false)
	_time_end = Time.get_unix_time_from_system()
	_time_elapsed = _time_end - _time_start
	SignalManager.on_timer_end.emit(_time_elapsed)
	SignalManager.on_loot_end.emit(_loot)


func start_game_timer(_val) -> void:
	_time = 0.0
	_time_start = Time.get_unix_time_from_system()
	set_process(true)


func on_player_hit(lives: int) -> void:
	for life in range(_hearts.size()):
		_hearts[life].visible = lives > life


func update_loot_score(loot: int) -> void:
	_loot += loot
	loot_score.text = "%03d" % _loot
