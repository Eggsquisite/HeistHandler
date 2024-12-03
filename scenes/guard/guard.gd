extends CharacterBody2D


enum EnemyState { IDLE, RUN, ATTACK }
enum GuardMode { PATROL, ALERT, SEARCH }


@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_bar: TextureProgressBar = $DetectionBar
@onready var detection_delay: Timer = $Timers/DetectionDelay
@onready var follow_delay: Timer = $Timers/FollowDelay
@onready var patrol_timer: Timer = $Timers/PatrolTimer
@onready var search_flip_timer: Timer = $Timers/SearchFlipTimer
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_shape: CollisionShape2D = $EnemyHitbox/CollisionShape2D
@onready var sound: AudioStreamPlayer2D = $Sound

@onready var sprite: Sprite2D = $Sprite2D
@onready var vision_cone: Area2D = $VisionCone
@onready var patrol_waypoints: Node2D = $PatrolWaypoints
@onready var detect_ray: RayCast2D = $DetectPlayerRay
@onready var attack_ray: RayCast2D = $AttackPlayerRay

const SPEED_MULT: float = 100
const DETECT_MULT: float = 10
const ATTACK_RANGE: float = 12.5

var _player: Node2D
var _state: EnemyState = EnemyState.IDLE
var _mode: GuardMode = GuardMode.PATROL
var _searching: bool = false
var _dec_detection: bool = false
var _player_sighted: bool = false
var _player_in_vision_area: bool = false
var _player_is_sneaking: bool = false
var _can_attack: bool = true
var _extra_searches: int = 0
var _last_player_pos: Vector2
var _player_pos: Array[Node2D]
var _waypoints: Array[Vector2]
var _wp_index: int = 0

var _sneak_detection_value: float
var _sneak_reduction_mult: float = 2.5

@export_group("Patrol Variables")
@export var patrol_speed: float = 12.5
@export var patrol_delay: float = 8

@export_group("Alert Variables")
@export var alert_speed: float = 35
@export var detection_inc: float = 6
@export var detection_dec: float = 3
@export var _extra_search_max: int = 1

@export_group("Search Variables")
@export var search_dur: float = 3
@export var search_delay: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	
	_sneak_detection_value = detection_inc
	_waypoints = patrol_waypoints.get_waypoints()
	detect_ray.enabled = false
	# hitbox_shape.disabled = true
	update_target()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_to_target(delta)
	detect_player(delta)
	check_raycast()
	calculate_states()
	attack_player()
	if _state != EnemyState.ATTACK:
		move_and_slide()


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	# velocity = velocity.move_toward(safe_velocity, 100)
	velocity = safe_velocity


func move_to_target(delta) -> void:
	# Do not move when attacking
	if _state == EnemyState.ATTACK:
		return
	
	var new_velocity: Vector2
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	if _mode == GuardMode.ALERT:
		new_velocity = lerp(new_velocity, direction * alert_speed * SPEED_MULT, delta)
	elif _mode == GuardMode.PATROL:
		new_velocity = lerp(new_velocity, direction * patrol_speed * SPEED_MULT, delta)
		# new_velocity = direction * patrol_speed * SPEED_MULT * delta

	if nav_agent.avoidance_enabled:
		nav_agent.velocity = new_velocity
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)


func _sort_by_distance_to_guard(pos1 : Node2D, pos2: Node2D):
	var pos1_to_guard = global_position.distance_to(pos1.global_position)
	var pos2_to_guard = global_position.distance_to(pos2.global_position)
	return pos1_to_guard > pos2_to_guard


func update_target() -> void: 
	if _mode == GuardMode.ALERT:
		nav_agent.target_position = _last_player_pos
	elif _mode == GuardMode.PATROL:
		# print("move to wp %s" % _waypoints[_wp_index])
		nav_agent.target_position = _waypoints[_wp_index]
	elif _mode == GuardMode.SEARCH:
		nav_agent.target_position = self.global_position


func calculate_states() -> void:
	if _state == EnemyState.ATTACK:
		return
	
	if velocity.x == 0 and velocity.y == 0:
		set_enemy_states(EnemyState.IDLE)
	elif velocity.x != 0 or velocity.y != 0:
		set_enemy_states(EnemyState.RUN)
		if velocity.x >= -0.1:
			sprite.flip_h = false
			attack_ray.target_position = Vector2(ATTACK_RANGE, 0)
			vision_cone.rotation_degrees = lerp(vision_cone.rotation_degrees, 0.0, 1)
		elif velocity.x <= 0.1:
			sprite.flip_h = true
			attack_ray.target_position = Vector2(-ATTACK_RANGE, 0)
			vision_cone.rotation_degrees = lerp(vision_cone.rotation_degrees, 180.0, 1)


func attack_player() -> void:
	if attack_ray.is_colliding():
		set_enemy_states(EnemyState.ATTACK)


func set_enemy_states(new_state: EnemyState) -> void:
	if _state == new_state:
		return
	_state = new_state
	
	match _state:
		EnemyState.IDLE:
			anim_player.play("idle")
		EnemyState.RUN:
			anim_player.play("run")
		EnemyState.ATTACK:
			if _can_attack:
				_can_attack = false
				anim_player.play("attack")


func set_guard_mode(new_mode: GuardMode) -> void:
	if _mode == new_mode:
		return
	_mode = new_mode
	
	match _mode:
		GuardMode.PATROL:
			follow_delay.stop()
			stop_search()
			update_target()
		GuardMode.ALERT:
			_extra_searches = _extra_search_max
			patrol_timer.stop()
			follow_delay.start()
			stop_search()
			update_last_player_pos()
			update_target()
		GuardMode.SEARCH:
			update_target()


func stop_search() -> void:
	_searching = false
	search_flip_timer.stop()


func update_last_player_pos() -> void:
	_player_pos.sort_custom(_sort_by_distance_to_guard)
	_last_player_pos = _player_pos[0].global_position


func _player_in_sight(flag: bool) -> void:
	if _player_sighted == flag:
		return
		
	_player_sighted = flag
	if _player_sighted:
		_dec_detection = false
		detection_delay.stop()
		_extra_searches = _extra_search_max
		
		if _mode == GuardMode.ALERT || _mode == GuardMode.SEARCH:
			update_last_player_pos()
			update_target()
	else:
		if _mode == GuardMode.ALERT: # If player LoS lost and guard is alerted, go to player's last known pos
			follow_delay.start()
			update_last_player_pos()
			update_target()
		elif _mode == GuardMode.PATROL || _mode == GuardMode.SEARCH:
			detection_delay.start()


func detect_player(delta) -> void:
	if _player != null:
		if _player.get_sneak_status():
			_sneak_detection_value = detection_inc / _sneak_reduction_mult
		else:
			_sneak_detection_value = detection_inc

	# is compares identity, == compares content
	if _player_sighted:
		if !detection_bar._get_is_alert():
			detection_bar.detection += _sneak_detection_value * delta * DETECT_MULT
		else:
			detection_bar.detection += 100 # Fill detection to max if already alerted
			set_guard_mode(GuardMode.ALERT)
	elif !_player_sighted and _dec_detection:
		if _mode == GuardMode.PATROL || _mode == GuardMode.SEARCH:
			detection_bar.detection -= detection_dec * delta * DETECT_MULT
			if !detection_bar._get_is_alert():
				set_guard_mode(GuardMode.PATROL)
		elif _mode == GuardMode.ALERT:
			if detection_bar._get_is_alert():
				set_guard_mode(GuardMode.SEARCH)
				detection_bar.detection -= detection_dec * delta * DETECT_MULT
	
	# if player leaves vision cone, keep following until a set time passes
	# if player not found after set time, reset to patrol path
	# if player is found, keep following player and reset time


func check_raycast() -> void:
	if _player != null:
		if _player_in_vision_area:
			var tmp = Vector2(_player.global_position.x, _player.global_position.y - 3)
			detect_ray.enabled = true
			detect_ray.target_position = global_position.direction_to(tmp) * 250
		
			if detect_ray.is_colliding():
				if detect_ray.get_collider() is Player:
					_player_in_sight(true)
				else:
					_player_in_sight(false)
			else:
				_player_in_sight(false)
		else:
			detect_ray.enabled = false


func flip_sprite() -> void:
	if sprite.flip_h:
		sprite.flip_h = false
		attack_ray.target_position = Vector2(ATTACK_RANGE, 0)
		vision_cone.rotation_degrees = lerp(vision_cone.rotation_degrees, 0.0, 1)
	else:
		sprite.flip_h = true
		attack_ray.target_position = Vector2(-ATTACK_RANGE, 0)
		vision_cone.rotation_degrees = lerp(vision_cone.rotation_degrees, 180.0, 1)


func face_player() -> void:
	if self.global_position.direction_to(_player.global_position) > Vector2.ZERO:
		sprite.flip_h = false
		attack_ray.target_position = Vector2(ATTACK_RANGE, 0)
		vision_cone.rotation_degrees = lerp(vision_cone.rotation_degrees, 0.0, 1)
	elif self.global_position.direction_to(_player.global_position) <= Vector2.ZERO:
		sprite.flip_h = true
		attack_ray.target_position = Vector2(-ATTACK_RANGE, 0)
		vision_cone.rotation_degrees = lerp(vision_cone.rotation_degrees, 180.0, 1)


func level_end() -> void:
	detection_bar.hide()
	set_enemy_states(EnemyState.IDLE)
	set_process(false)
	set_physics_process(false)


func play_sword_slash() -> void:
	SoundManager.play_clip(sound, SoundManager.SOUND_SLASH)


func _on_vision_cone_body_entered(body: Node2D) -> void:
	if _player == null:
		_player = body
		_player_pos = _player.get_nav_points()
	
	# _player_in_sight(true)
	_player_in_vision_area = true


func _on_vision_cone_body_exited(body: Node2D) -> void:
	_player_in_sight(false)
	_player_in_vision_area = false


func _on_navigation_agent_2d_target_reached() -> void:
	# If patrolling and reached waypoint, update nav_target to next waypoint
	if _mode == GuardMode.SEARCH and !_searching:
		_searching = true
		call_deferred("flip_sprite")
		search_flip_timer.start(search_delay)
	elif _mode == GuardMode.ALERT:
		if !_player_sighted and _extra_searches == 0:
			follow_delay.stop()
			detection_delay.start()
		else:
			face_player()
	elif _mode == GuardMode.PATROL:
		if _wp_index < _waypoints.size() - 1:
			_wp_index += 1
		else:
			_wp_index = 0
		patrol_timer.start(patrol_delay)



func _on_detection_delay_timeout() -> void:
	_dec_detection = true


func _on_follow_delay_timeout() -> void:
	if _player_sighted:
		update_last_player_pos()
	elif !_player_sighted and _extra_searches > 0:
		_extra_searches -= 1
		update_last_player_pos()
	update_target()


func _on_patrol_delay_timeout() -> void:
	# call_deferred("update_target")
	update_target()


func _on_search_flip_timer_timeout() -> void:
	call_deferred("flip_sprite")


func _on_player_detect_area_body_entered(body: Node2D) -> void:
	# Fill detection to max when player touches guard
	detection_bar.detection += 100 


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		_can_attack = true
		set_enemy_states(EnemyState.IDLE)
