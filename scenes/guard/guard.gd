extends CharacterBody2D


enum GuardState { IDLE, PATROL, ALERT }


@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

const SPEED_MULT: float = 100

var _state: GuardState = GuardState.IDLE

@export var speed: float = 12

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nav_agent.navigation_finished.connect(_on_nav_finished)
	nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	# make_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var target_pos = get_tree().get_first_node_in_group("player").position
	nav_agent.target_position = target_pos
	
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	var new_velocity = direction * speed * SPEED_MULT * delta
	
	if nav_agent.avoidance_enabled:
		nav_agent.velocity = new_velocity
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	move_and_slide()

func _on_nav_finished():
	if _state == GuardState.PATROL:
		pass
	elif _state == GuardState.ALERT:
		pass


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, 100)
