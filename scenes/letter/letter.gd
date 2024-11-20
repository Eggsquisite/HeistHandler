extends CenterContainer


@onready var letter: Label = $VBoxContainer/CoverContainer/Letter
@onready var cover: Sprite2D = $VBoxContainer/CoverContainer/Cover2
@onready var selector: Sprite2D = $VBoxContainer/SelectorContainer/Selector
@onready var timer: Timer = $Timer

var is_hidden: bool = false


func get_letter() -> Label:
	return letter


func hide_letter() -> void:
	is_hidden = true
	cover.show()
	mouse_filter = MOUSE_FILTER_PASS
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	focus_mode = FOCUS_ALL


func show_letter() -> void:
	is_hidden = false
	selector.hide()
	cover.hide()
	mouse_filter = MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = CURSOR_ARROW
	focus_next
	# Play unlock sound


func _on_focus_entered() -> void:
	# If letter is covered, allow to be lockpicked
	if cover.visible:
		selector.show()


func _on_focus_exited() -> void:
	end_lockpick()
	selector.hide()
	if !is_hidden:
		focus_mode = FOCUS_NONE


func begin_lockpick(duration: float) -> void:
	if is_hidden and has_focus():
		timer.start(duration)
		# play unlocking sound


func end_lockpick() -> void:
	timer.stop()


func _on_timer_timeout() -> void:
	show_letter()
	# end unlocking sound
