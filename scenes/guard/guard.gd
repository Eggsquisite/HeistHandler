extends CharacterBody2D


enum GuardState { IDLE, RUN, ATTACK }


@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

const SPEED_MULT: float = 100
const MAX_DETECTION: float = 100

var _state: GuardState = GuardState.IDLE
var _target_pos: Array[Node2D]
var _player_sighted: bool = false
var _alerted: bool = false
var _player_is_sneaking: bool = false
var _player: Node2D

var _detection_level: float = 0
var _sneak_detection_value: float

@export var speed: float = 12
@export var detection_inc: float = 1
@export var detection_dec: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nav_agent.navigation_finished.connect(_on_nav_finished)
	nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	# make_path()
	# _target_pos = get_tree().get_first_node_in_group("player").get_nav_points()
	_sneak_detection_value = detection_inc


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if _target_pos != []:
		_target_pos.sort_custom(_sort_by_distance_to_guard)
		nav_agent.target_position = _target_pos[0].global_position
	
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	var new_velocity = direction * speed * SPEED_MULT * delta
	
	if nav_agent.avoidance_enabled:
		nav_agent.velocity = new_velocity
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	move_and_slide()
	_detect_player(delta)


func _on_nav_finished():
	if _alerted:
		pass
	else:
		pass


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	# velocity = velocity.move_toward(safe_velocity, 100)
	velocity = safe_velocity


func _sort_by_distance_to_guard(pos1 : Node2D, pos2: Node2D):
	var pos1_to_guard = global_position.distance_to(pos1.global_position)
	var pos2_to_guard = global_position.distance_to(pos2.global_position)
	return pos1_to_guard < pos2_to_guard


func calculate_states() -> void:
	pass


func set_states(new_state: GuardState) -> void:
	if _state == new_state:
		return
	
	_state = new_state


func _on_vision_cone_body_entered(body: Node2D) -> void:
	if body == get_tree().get_first_node_in_group("player"):
		_player_in_sight(true)
		if _player == null:
			_player = body


func _on_vision_cone_body_exited(body: Node2D) -> void:
	if body == get_tree().get_first_node_in_group("player"):
		_player = null
		_player_in_sight(false)


func _player_in_sight(flag: bool) -> void:
	if _player_sighted == flag:
		return
		
	_player_sighted = flag


func _detect_player(delta) -> void:
	if _player != null:
		var sneak = _player.get_sneak_status()
		if sneak and !_player_is_sneaking:
			_player_is_sneaking = true
			_sneak_detection_value = detection_inc / 2
		elif !sneak and _player_is_sneaking:
			_player_is_sneaking = false
			_sneak_detection_value = detection_inc
	else:
		if _player_is_sneaking:
			_player_is_sneaking = false
			_sneak_detection_value = detection_inc
	
	
	if _player_sighted:
		if _detection_level < MAX_DETECTION:
			_detection_level += _sneak_detection_value * delta
		elif _detection_level >= MAX_DETECTION:
			_set_alerted(true)
			_detection_level = MAX_DETECTION
	else:
		if _detection_level > 0:
			_detection_level -= detection_dec * delta
			# print(_detection_level)
		elif _detection_level < 0:
			_set_alerted(false)
			_detection_level = 0


func _set_alerted(flag: bool) -> void:
	print("_alerted")
	if _alerted == flag:
		return
	
	_alerted = flag
	print(_alerted)
	if _alerted and _player != null:
		_target_pos = _player.get_nav_points()
	
	# if player leaves vision cone, go to last known position
	# if player not found after set time, reset to patrol path
	# if player is found, keep following player
