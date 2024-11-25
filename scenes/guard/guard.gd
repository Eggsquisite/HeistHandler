extends CharacterBody2D


enum EnemyState { IDLE, RUN, ATTACK }
enum GuardMode { PATROL, ALERT, SEARCH }


@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_bar: ProgressBar = $DetectionBar
@onready var detection_delay: Timer = $DetectionDelay
@onready var follow_delay: Timer = $FollowDelay
@onready var patrol_timer: Timer = $PatrolTimer
@onready var search_duration: Timer = $SearchDuration
@onready var search_flip_timer: Timer = $SearchFlipTimer


@onready var sprite: Sprite2D = $Sprite2D
@onready var vision_cone: Area2D = $VisionCone
@onready var patrol_waypoints: Node2D = $PatrolWaypoints

const SPEED_MULT: float = 100
const DETECT_MULT: float = 10

var _player: Node2D
var _state: EnemyState = EnemyState.IDLE
var _mode: GuardMode = GuardMode.PATROL
var _searching: bool = false
var _dec_detection: bool = false
var _player_sighted: bool = false
var _player_is_sneaking: bool = false
var _last_player_pos: Vector2
var _player_pos: Array[Node2D]
var _waypoints: Array[Vector2]
var _wp_index: int = 0

var _sneak_detection_value: float

@export_group("Patrol Variables")
@export var patrol_speed: float = 25
@export var patrol_delay: float = 2

@export_group("Alert Variables")
@export var alert_speed: float = 40
@export var detection_inc: float = 8
@export var detection_dec: float = 4

@export_group("Search Variables")
@export var search_dur: float = 3
@export var search_delay: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nav_agent.navigation_finished.connect(_on_nav_finished)
	nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	# make_path()
	# _target_pos = get_tree().get_first_node_in_group("player").get_nav_points()
	_sneak_detection_value = detection_inc
	_waypoints = patrol_waypoints.get_waypoints()
	print("waypoints:")
	print(_waypoints)
	update_target()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_to_target(delta)
	detect_player(delta)
	move_and_slide()
	calculate_states()


func _on_nav_finished():
	if _mode == GuardMode.ALERT:
		pass
	else:
		pass


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	# velocity = velocity.move_toward(safe_velocity, 100)
	velocity = safe_velocity


func update_target() -> void: 
	# print("updating...")
	if _mode == GuardMode.ALERT:
		_player_pos.sort_custom(_sort_by_distance_to_guard)
		nav_agent.target_position = _player_pos[0].global_position
	elif _mode == GuardMode.PATROL:
		print("move to wp %s" % _waypoints[_wp_index])
		nav_agent.target_position = _waypoints[_wp_index]
	elif _mode == GuardMode.SEARCH:
		nav_agent.target_position = _last_player_pos


func move_to_target(delta) -> void:
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	var new_velocity = direction * alert_speed * SPEED_MULT * delta
	#if _mode == GuardMode.ALERT:
		#new_velocity = direction * alert_speed * SPEED_MULT * delta
	#elif _mode == GuardMode.PATROL:
		#new_velocity = direction * patrol_speed * SPEED_MULT * delta

	if nav_agent.avoidance_enabled:
		nav_agent.velocity = new_velocity
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)


func _sort_by_distance_to_guard(pos1 : Node2D, pos2: Node2D):
	var pos1_to_guard = global_position.distance_to(pos1.global_position)
	var pos2_to_guard = global_position.distance_to(pos2.global_position)
	return pos1_to_guard < pos2_to_guard


func calculate_states() -> void:
	if velocity.x == 0 and velocity.y == 0:
		set_enemy_states(EnemyState.IDLE)
	elif velocity.x != 0 or velocity.y != 0:
		set_enemy_states(EnemyState.RUN)
		if velocity.x < 0:
			sprite.flip_h = true
			vision_cone.rotation_degrees = lerp(vision_cone.rotation_degrees, 180.0, 0.9)
		elif velocity.x > 0:
			sprite.flip_h = false
			vision_cone.rotation_degrees = lerp(vision_cone.rotation_degrees, 0.0, 0.9)


func set_enemy_states(new_state: EnemyState) -> void:
	if _state == new_state:
		return
	
	_state = new_state


func set_guard_mode(new_mode: GuardMode) -> void:
	if _mode == new_mode:
		return
	_mode = new_mode
	
	match _mode:
		GuardMode.PATROL:
			_player_pos = []
			follow_delay.stop()
			stop_search()
			update_target()
		GuardMode.ALERT:
			_player_pos = _player.get_nav_points()
			follow_delay.start()
			stop_search()
			update_target()
		GuardMode.SEARCH:
			_player_pos.sort_custom(_sort_by_distance_to_guard)
			_last_player_pos = _player_pos[0].global_position


func stop_search() -> void:
	_searching = false
	search_duration.stop()
	search_flip_timer.stop()


func _on_vision_cone_body_entered(body: Node2D) -> void:
	_player_in_sight(true)
	_dec_detection = false
	if _player == null:
		_player = body
		_player_pos = _player.get_nav_points()
		update_target()


func _on_vision_cone_body_exited(body: Node2D) -> void:
	if _player != null:
		_player = null
	
	#if _mode == GuardMode.ALERT: # If player LoS lost and guard is alerted, go to player's last known pos
		#_player_pos.sort_custom(_sort_by_distance_to_guard)
		#_last_player_pos = _player_pos[0].global_position
		#update_target()
	
	_player_in_sight(false)
	detection_delay.start()


func _player_in_sight(flag: bool) -> void:
	if _player_sighted == flag:
		return
		
	_player_sighted = flag


func detect_player(delta) -> void:
	if _player != null:
		if _player.get_sneak_status():
			_sneak_detection_value = detection_inc / 2
		else:
			_sneak_detection_value = detection_inc
	
	if _player_sighted:
		if !detection_bar._get_is_alert():
			detection_bar.detection += _sneak_detection_value * delta * DETECT_MULT
		if detection_bar._get_is_alert():
			detection_bar.detection += 100 # Fill detection to max if already alerted
			set_guard_mode(GuardMode.ALERT)
	elif !_player_sighted and _dec_detection:
		detection_bar.detection -= detection_dec * delta * DETECT_MULT
		if !detection_bar._get_is_alert():
			if _mode == GuardMode.ALERT:
				set_guard_mode(GuardMode.SEARCH)
	
	# if player leaves vision cone, keep following until a set time passes
	# if player not found after set time, reset to patrol path
	# if player is found, keep following player and reset time


func _on_follow_delay_timeout() -> void:
	update_target()


func _on_detection_delay_timeout() -> void:
	_dec_detection = true


func _on_navigation_agent_2d_target_reached() -> void:
	# If patrolling and reached waypoint, update nav_target to next waypoint
	if _mode == GuardMode.SEARCH and !_searching:
		_searching = true
		search_duration.start(search_dur)
		search_flip_timer.start(search_delay)
	elif _mode == GuardMode.PATROL:
		if _wp_index < _waypoints.size() - 1:
			_wp_index += 1
		else:
			_wp_index = 0
		patrol_timer.start(patrol_delay)


func _on_patrol_delay_timeout() -> void:
	# call_deferred("update_target")
	#if _mode == GuardMode.SEARCH:
		#search_duration.stop()
		#set_guard_mode(GuardMode.PATROL)
	update_target()


func _on_search_duration_timeout() -> void:
	print("patrol")
	# set_guard_mode(GuardMode.PATROL)


func _on_search_flip_timer_timeout() -> void:
	if sprite.flip_h:
		sprite.flip_h = false
		vision_cone.rotation_degrees = lerp(vision_cone.rotation_degrees, 0.0, 1)
	else:
		sprite.flip_h = true
		vision_cone.rotation_degrees = lerp(vision_cone.rotation_degrees, 180.0, 1)
