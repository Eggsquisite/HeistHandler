extends Control

@onready var empty_star = "res://assets/ui/single_star_empty.png"
@onready var full_star = "res://resources/full_star/full_star.tres"
@onready var hb_hearts: HBoxContainer = $MC/HB/VB/HBHearts
@onready var hb_loot: HBoxContainer = $MC/HB/VB/HBLoot
@onready var loot_score: Label = $MC/HB/VB/HBLoot/LootScore
@onready var t_loot1: Label = $MC/HB/VB/HBLoot/TotalLoot1
@onready var current_timer: Panel = $MC/HB/CurrentTimer
@onready var c_mins: Label = $MC/HB/CurrentTimer/Minutes
@onready var c_secs: Label = $MC/HB/CurrentTimer/Seconds
@onready var c_msecs: Label = $MC/HB/CurrentTimer/Msecs
@onready var go_rect: ColorRect = $GORect
@onready var lc_rect: ColorRect = $LCRect

@onready var hb_stars: HBoxContainer = $LCRect/VBLC/HBStars
@onready var lc_label: Label = $LCRect/VBLC/LCLabel
@onready var t_loot2: Label = $LCRect/VBLC/HB/HB/TotalLoot2
@onready var t_mins: Label = $LCRect/VBLC/HB/TotalTimer/TotalMinutes
@onready var t_secs: Label = $LCRect/VBLC/HB/TotalTimer/TotalSeconds
@onready var t_msecs: Label = $LCRect/VBLC/HB/TotalTimer/TotalMsecs

var _hearts: Array
var _stars: Array
var _loot: int = 0
var _total_loot: int = 0
var _time: float = 0.0
var _time_start: float = 0.0
var _time_end: float = 0.0
var _time_elapsed: float = 0.0
var _mins: int = 0
var _secs: int = 0
var _msecs: int = 0
var _level_number: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	_hearts = hb_hearts.get_children()
	_stars = hb_stars.get_children()
	_level_number = GameManager.get_level_selected()
	SignalManager.on_player_hit.connect(on_player_hit)
	SignalManager.on_player_started.connect(on_player_hit)
	SignalManager.on_level_started.connect(start_level)
	SignalManager.on_level_complete.connect(level_complete)
	SignalManager.on_loot_pickup.connect(update_loot_score)
	SignalManager.on_rank_set.connect(set_rank)
	SignalManager.on_game_over.connect(game_over)


func _process(delta: float) -> void:
	_time += delta
	_msecs = fmod(_time, 1) * 100
	_secs = fmod(_time, 60)
	_mins = fmod(_time, 3600) / 60
	c_mins.text = "%02d:" % _mins
	c_secs.text = "%02d" % _secs
	c_msecs.text = ".%02d" % _msecs


func start_level(total_loot) -> void:
	_loot = 0
	_time = 0.0
	_total_loot = total_loot
	_time_start = Time.get_unix_time_from_system()
	loot_score.text = ":%03d/" % _loot
	t_loot1.text = "%03d" % _total_loot
	set_process(true)


func on_player_hit(lives: int) -> void:
	for life in range(_hearts.size()):
		_hearts[life].visible = lives > life


func level_complete() -> void:
	set_process(false)
	lc_rect.show()
	_time_end = Time.get_unix_time_from_system()
	_time_elapsed = _time_end - _time_start
	SignalManager.on_score_end.emit(_loot, _time_elapsed, str(_level_number))


func set_rank(rank: int) -> void:
	hb_loot.hide()
	current_timer.hide()
	lc_label.text = "Level %d Complete" % _level_number
	
	t_loot2.text = ":%03d / %03d" % [_loot, _total_loot]
	
	_msecs = fmod(_time_elapsed, 1) * 100
	_secs = fmod(_time_elapsed, 60)
	_mins = fmod(_time_elapsed, 3600) / 60
	t_mins.text = "%02d:" % _mins
	t_secs.text = "%02d" % _secs
	t_msecs.text = ".%02d" % _msecs
	
	for star in range(_stars.size()):
		if rank > star:
			_stars[star].texture = load(full_star)
		else:
			_stars[star].texture = load(empty_star)


func update_loot_score(loot: int) -> void:
	_loot += loot
	loot_score.text = ":%03d/" % _loot


func game_over() -> void:
	set_process(false)
	go_rect.show()
