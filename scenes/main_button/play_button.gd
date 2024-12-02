extends TextureButton

const HOVER_SCALE = Vector2(1.1, 1.1)
const DEFAULT_SCALE = Vector2(1.0, 1.0)


func _on_mouse_entered() -> void:
	scale = HOVER_SCALE


func _on_mouse_exited() -> void:
	scale = DEFAULT_SCALE


func _on_pressed() -> void:
	SignalManager.on_play_button_pressed.emit()
