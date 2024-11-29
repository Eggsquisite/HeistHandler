extends CharacterBody2D


class_name Player

enum PlayerState { IDLE, RUN, SNEAK_IDLE, SNEAK_WALK, LOCKPICK, HURT, DEATH }

const RUN_SPEED: float = 100.0
const SNEAK_SPEED: float = 60.0
const LOCKPICK_SPEED: float = 1.0
const LOCKPICK_MULTIPLIER: float = 2.0


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var debug_label: Label = $DebugLabel
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var invincible_player: AnimationPlayer = $InvinciblePlayer
@onready var nav_points: Node2D = $NavPoints
@onready var hitbox_collision: CollisionShape2D = $Hurtbox/HitboxCollision2D


var _state: PlayerState = PlayerState.IDLE
var _sneaking: bool = false
var _interacting: bool = false
var _invincible: bool = false
var _max_health: int = 1
var _current_health: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_current_health = _max_health
	call_deferred("late_setup")
	SignalManager.word_game_started.connect(set_interact_true)
	SignalManager.word_game_finished.connect(set_interact_false)


func late_setup() -> void:
	SignalManager.on_level_started.emit(_current_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	calculate_states()
	update_debug_label()


func update_debug_label() -> void:
	debug_label.text = "%s\nhealth:%s\ninv:%s)" % [
		PlayerState.keys()[_state],
		_current_health,
		_invincible
		]


func get_input() -> void:
	velocity.x = 0
	velocity.y = 0
	
	if _interacting || _state == PlayerState.HURT:
		return
	
	if _sneaking:
		calculate_movement(SNEAK_SPEED)
	else:
		calculate_movement(RUN_SPEED)

	if Input.is_action_pressed("sneak"):
		set_sneaking(true)
	elif Input.is_action_just_released("sneak"):
		set_sneaking(false)


func calculate_movement(speed: float) -> void:
	if Input.is_action_pressed("up"):
		velocity.y = -speed
	elif Input.is_action_pressed("down"):
		velocity.y = speed
	
	if Input.is_action_pressed("left"):
		velocity.x = -speed
		sprite_2d.flip_h = true
	elif Input.is_action_pressed("right"):
		velocity.x = speed
		sprite_2d.flip_h = false


func calculate_states() -> void:
	if _state == PlayerState.HURT:
		return
	
	if _interacting:
		set_sneaking(true)
		set_state(PlayerState.LOCKPICK)
	elif velocity.x == 0 and velocity.y == 0:
		if _sneaking:
			set_state(PlayerState.SNEAK_IDLE)
		else:
			set_state(PlayerState.IDLE)
	elif velocity.x != 0 or velocity.y != 0:
		if _sneaking: 
			set_state(PlayerState.SNEAK_WALK)
		else:
			set_state(PlayerState.RUN)


func set_state(new_state: PlayerState) -> void:
	if new_state == _state:
		return
	
	_state = new_state
	
	match _state:
		PlayerState.IDLE:
			anim_player.play("idle")
		PlayerState.RUN:
			anim_player.play("walk")
		PlayerState.SNEAK_IDLE:
			anim_player.play("sneak_idle")
		PlayerState.SNEAK_WALK:
			anim_player.play("sneak_walk")
		PlayerState.LOCKPICK:
			anim_player.play("sneak_idle")
		PlayerState.HURT:
			anim_player.play("hurt")
		PlayerState.DEATH:
			anim_player.play("death")


func set_sneaking(sneak_flag: bool) -> void:
	if _sneaking == sneak_flag:
		return
		
	_sneaking = sneak_flag


func set_interact_true() -> void:
	if _interacting == true:
		return
	
	_interacting = true


func set_interact_false(flag) -> void:
	if _interacting == false:
		return

	# Edge case if player is sneaking when lockpicking
	set_sneaking(false)
	_interacting = false


func get_nav_points() -> Array[Node2D]:
	var nodes: Array[Node2D]
	for n in nav_points.get_children():
		nodes.append(n)
	return nodes


func get_sneak_status() -> bool:
	return _sneaking


func apply_hit() -> void:
	if _invincible:
		return

	if reduce_health(1) == false:
		return
	
	set_state(PlayerState.HURT)
	go_invincible()


func reduce_health(reduction: int) -> bool:
	_current_health -= reduction
	SignalManager.on_player_hit.emit(_current_health)
	if _current_health <= 0:
		set_state(PlayerState.DEATH)
		SignalManager.on_game_over.emit()
		set_physics_process(false)
		return false
	return true


func go_invincible() -> void:
	_invincible = true
	invincible_timer.start()
	hitbox_collision.disabled = true
	invincible_player.play("invincible")


func get_invincible() -> bool:
	return _invincible


func _on_invincible_timer_timeout() -> void:
	_invincible = false
	hitbox_collision.disabled = false
	invincible_player.stop()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	apply_hit()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt":
		set_state(PlayerState.IDLE)
