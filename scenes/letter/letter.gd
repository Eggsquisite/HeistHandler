extends CenterContainer


@onready var letter: Label = $Letter
@onready var letter_cover: Sprite2D = $LetterCover
@onready var selector: Sprite2D = $Selector
@onready var timer: Timer = $Timer

var is_hidden: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("lockpick") and is_hidden and has_focus():
		begin_lockpick(1)


func get_letter() -> Label:
	return letter


func hide_letter() -> void:
	is_hidden = true
	letter_cover.show()


func show_letter() -> void:
	is_hidden = false
	selector.hide()
	letter_cover.hide()
	# Play unlock sound


func _on_focus_entered() -> void:
	# If letter is covered, allow to be lockpicked
	if letter_cover.visible:
		selector.show()


func _on_focus_exited() -> void:
	end_lockpick()
	selector.hide()


func begin_lockpick(duration: float) -> void:
	timer.start(duration)
	# play unlocking sound


func end_lockpick() -> void:
	timer.stop()


func _on_timer_timeout() -> void:
	show_letter()
	# end unlocking sound
