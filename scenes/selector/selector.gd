extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start_unlock() -> void:
	animation_player.play("idle")


func stop_unlock() -> void:
	animation_player.stop()
