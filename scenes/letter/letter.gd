extends CenterContainer


@onready var letter: Label = $VBoxContainer/CoverContainer/Letter
@onready var shield_lock: Node2D = $"VBoxContainer/CoverContainer/Shield Lock"
@onready var selector: Node2D = $VBoxContainer/SelectorContainer/Selector
@onready var timer: Timer = $Timer

var is_hidden: bool = false
var no_more_reveals: bool = false
var is_being_lockpicked: bool = false


func get_letter() -> Label:
	return letter


func hide_letter() -> void:
	is_hidden = true
	shield_lock.show()
	reenable_focus()


func show_letter() -> void:
	if no_more_reveals:
		return
	
	# shield_lock.hide()
	shield_lock.play_unlock()
	selector.hide()
	is_hidden = false
	disable_focus()
	focus_next
	# Play unlock sound


func word_finished() -> void:
	shield_lock.play_unlock()
	selector.hide()
	disable_focus()


func no_more_reveal() -> void:
	if !is_hidden: # if letter is shown, no need change anything
		return
	
	no_more_reveals = true
	disable_focus()


func disable_focus() -> void:
	focus_mode = FOCUS_NONE
	mouse_filter = MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = CURSOR_ARROW


func reenable_focus() -> void:
	if !is_hidden:
		return
	
	focus_mode = FOCUS_ALL
	mouse_filter = MOUSE_FILTER_PASS
	mouse_default_cursor_shape = CURSOR_POINTING_HAND


func _on_focus_entered() -> void:
	# If letter is covered, allow to be lockpicked
	if shield_lock.visible:
		selector.show()
	
	if is_being_lockpicked:
		selector.start_unlock()


func _on_focus_exited() -> void:
	end_lockpick()
	selector.hide()
	if !is_hidden:
		focus_mode = FOCUS_NONE


func begin_lockpick(duration: float) -> void:
	if is_hidden:
		self.grab_focus()
		selector.start_unlock()
		timer.start(duration)
		is_being_lockpicked = true
		# play unlocking sound


func end_lockpick() -> void:
	timer.stop()
	selector.stop_unlock()
	is_being_lockpicked = false


func _on_timer_timeout() -> void:
	show_letter()
	# end unlocking sound
