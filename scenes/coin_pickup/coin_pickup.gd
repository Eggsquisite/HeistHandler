extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_timer: Timer = $LifeTimer
@onready var move_timer: Timer = $MoveTimer
@onready var coll: CollisionShape2D = $CollisionShape2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var warn_player: AnimationPlayer = $WarningPlayer

var value_amt: int
var target_pos: Vector2
var travel_dur: float = 0.7
var life_dur: float = 7.0
var warn_dur: float = 3.0
var last_chance: bool = false
@export_enum("copper", "silver") var type: String = "copper"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_coin(type, false)


func setup_coin(coin_type: String, timer_flag: bool) -> void:
	if coin_type == "copper":
		anim.play("copper")
		value_amt = 1
	elif coin_type == "silver":
		anim.play("silver")
		value_amt = 5
	
	if timer_flag:
		life_timer.start(life_dur)
	else:
		life_timer.stop()
		coll.disabled = false


func move_to_location(start_pos: Vector2, pos: Vector2) -> void:
	target_pos = pos
	anim_player.play("travel")
	
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, travel_dur).from(start_pos)


func get_loot_amt() -> int:
	return value_amt


func release_me() -> void:
	hide()
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	anim.stop()
	life_timer.stop()
	warn_player.stop()
	anim_player.play("pickup")
	SignalManager.on_loot_pickup.emit(value_amt)
	# play sound


func _on_life_timer_timeout() -> void:
	if last_chance:
		release_me()
	else:
		last_chance = true
		life_timer.start(warn_dur)
		warn_player.play("warning")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pickup":
		release_me()
