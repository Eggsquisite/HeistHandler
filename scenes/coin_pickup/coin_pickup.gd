extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_timer: Timer = $LifeTimer

var value_amt: int
var target_pos: Vector2
var can_move: bool = false
var speed: float = 20
@export_enum("copper", "silver") var type: String = "copper"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_coin(type, false)


func _physics_process(delta: float) -> void:
	if can_move:
		move_to_location()


func setup_coin(coin_type: String, timer_flag: bool) -> void:
	if coin_type == "copper":
		anim.play("copper")
		value_amt = 1
	elif coin_type == "silver":
		anim.play("silver")
		value_amt = 5
	
	if timer_flag:
		life_timer.start()
	else:
		life_timer.stop()


func set_move_location(pos: Vector2) -> void:
	can_move = true
	target_pos = pos


func move_to_location() -> void:
	if global_position == target_pos:
		can_move = false
		return
	global_position = global_position.direction_to(target_pos) * speed


func release_me() -> void:
	hide()
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	SignalManager.on_loot_pickup.emit(value_amt)
	# play sound
	release_me()


func _on_life_timer_timeout() -> void:
	release_me()
