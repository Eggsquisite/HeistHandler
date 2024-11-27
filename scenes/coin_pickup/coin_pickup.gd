extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ln: Array[String] = []
	for an in anim.sprite_frames.get_animation_names():
		ln.push_back(an)
	anim.animation = ln.pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn_coins(pos: Vector2, coin_type: String, coin_amt: int) -> void:
	pass
