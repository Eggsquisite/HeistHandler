extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var word_game: CenterContainer = $WordGame


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(word_game, "start_minigame")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
