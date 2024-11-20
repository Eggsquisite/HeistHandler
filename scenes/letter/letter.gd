extends CenterContainer


@onready var letter: Label = $VBoxContainer/CoverContainer/Letter
@onready var cover: Sprite2D = $VBoxContainer/CoverContainer/Cover2
@onready var red_cover: Sprite2D = $VBoxContainer/CoverContainer/RedCover
@onready var selector: Sprite2D = $VBoxContainer/SelectorContainer/Selector
@onready var timer: Timer = $Timer

var is_hidden: bool = false
var no_more_reveals: bool = false


func get_letter() -> Label:
	return letter


func hide_letter() -> void:
	is_hidden = true
	cover.show()
	focus_mode = FOCUS_ALL
	mouse_filter = MOUSE_FILTER_PASS
	mouse_default_cursor_shape = CURSOR_POINTING_HAND


func show_letter() -> void:
	if no_more_reveals:
		return
	
	cover.hide()
	selector.hide()
	is_hidden = false
	disable_focus()
	focus_next
	# Play unlock sound


func word_finished() -> void:
	cover.hide()
	selector.hide()
	red_cover.hide()
	disable_focus()


func no_more_reveal() -> void:
	if !is_hidden: # if letter is shown, no need change anything
		return
	
	cover.hide()
	red_cover.show()
	no_more_reveals = true
	disable_focus()


func disable_focus() -> void:
	focus_mode = FOCUS_NONE
	mouse_filter = MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = CURSOR_ARROW


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
