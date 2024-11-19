extends CharacterBody2D


class_name Player

enum PlayerState { IDLE, RUN, SNEAK_IDLE, SNEAK_WALK, LOCKPICK, HURT }

const RUN_SPEED: float = 100.0
const SNEAK_SPEED: float = 60.0
const LOCKPICK_SPEED: float = 1.0
const LOCKPICK_MULTIPLIER: float = 2.0


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var debug_label: Label = $DebugLabel


var _state: PlayerState = PlayerState.IDLE
var _sneaking: bool = false
var _interacting: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.word_game_started.connect(set_interact_true)
	SignalManager.word_game_finished.connect(set_interact_false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	calculate_states()
	update_debug_label()


func update_debug_label() -> void:
	debug_label.text = "%s\nsneak:%s\nvel:(%.0f,%.0f)" % [
		PlayerState.keys()[_state],
		_sneaking,
		velocity.x,
		velocity.y,
		]


func get_input() -> void:
	velocity.x = 0
	velocity.y = 0
	
	if _interacting:
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
	if _interacting:
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
