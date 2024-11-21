extends Node2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_unlock() -> void:
	animation_player.play("unlock")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "unlock":
		self.hide()
