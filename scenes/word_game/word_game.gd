extends CenterContainer

@onready var full_word_container: HBoxContainer = $"Control/ColorRect/VBoxContainer/Full Word Container"
@onready var line_edit: LineEdit = $Control/ColorRect/VBoxContainer/LineEdit
@onready var lockpick_timer: Timer = $LockpickTimer
@onready var success_timer: Timer = $SuccessTimer
@onready var color_rect: ColorRect = $ColorRect
@onready var lock_status: Label = $Control/ColorRect/VBoxContainer/LockStatus

var letter_node = preload("res://scenes/letter/letter.tscn")

var full_word: String = ''
var letter_index: int
var index_array: Array[int] = []
var letter_containers: Array[Node] = []
var letter_array: Array[String] = []

var tries_left: int = 0
var lockpick_count: int = 0
var control_focus: Control
var is_game_started: bool = false
var is_lockpick_started: bool = false
var is_lock_picked: bool = false

@export var max_tries: int = 3
@export var difficulty: int = 1
@export var time_to_pick: float = 1
@export var multiplier_to_pick: float = 1.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# color_rect.set_size(Vector2(100, 100))
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and !is_game_started:
		start_minigame()
	
	if Input.is_action_just_pressed("lockpick") and !is_lockpick_started:
		control_focus = get_viewport().gui_get_focus_owner()
		if control_focus != null and control_focus != line_edit:
			begin_lockpick()


func start_minigame() -> void:
	self.show()
	is_game_started = true
	tries_left = max_tries
	line_edit.grab_focus()
	update_lock_label()
	setup_line_edit()
	
	full_word = WordManager.get_random_word(difficulty)
	print(full_word)
	for letter in full_word:
		letter_array.append(letter)
	
	print(letter_array)
	for letter in letter_array:
		var letter_instance = letter_node.instantiate()
		full_word_container.add_child(letter_instance)
		
		letter_instance.get_letter().text = letter
		letter_containers.append(letter_instance)

	randomize_letter(difficulty, letter_containers.size() - 1)


func randomize_letter(difficulty: int, size: int) -> void:
	for n in range(0, size + 1, 1):
		index_array.append(n)
	
	# Get a random index, then remove that index from index_array to prevent dupes
	for n in range(0, difficulty + 1, 1):
		letter_index = index_array.pick_random()
		index_array.erase(letter_index)
		letter_containers[letter_index].hide_letter()
	
	index_array.clear()


func setup_line_edit() -> void:
	line_edit.grab_focus()
	line_edit.max_length = difficulty + 3


func update_lock_label() -> void:
	if is_lock_picked:
		lock_status.text = "Lock unlocked!"
	elif tries_left > 0:
		lock_status.text = "%s tries left!" % tries_left
	elif tries_left <= 0:
		lock_status.text = "Lock is broken!"


func success() -> void:
	if is_lock_picked:
		return
	
	# Will queue_free at end of timer
	success_timer.start()
	
	is_lock_picked = true 
	update_lock_label()
	for n in full_word_container.get_children():
		n.show_letter()
	# reward player
	# play unlock sound


func failure() -> void:
	tries_left -= 1
	line_edit.clear()
	update_lock_label()
	
	if tries_left <= 0:
		# play lock broken sound
		end_minigame()


func end_minigame() -> void:
	full_word = ''
	tries_left = max_tries
	is_game_started = false
	is_lock_picked = false
	is_lockpick_started = false
	index_array.clear()
	letter_array.clear()
	letter_containers.clear()
	line_edit.hide()
	line_edit.show()
	line_edit.clear()
	
	for n in full_word_container.get_children():
		full_word_container.remove_child(n)
	# queue_free()


func begin_lockpick() -> void:
	is_lockpick_started = true
	lockpick_count += 1
	control_focus.grab_focus()
	lockpick_timer.start(time_to_pick * (multiplier_to_pick * lockpick_count))
	# play unlocking sound


func end_lockpick() -> void:
	control_focus.show_letter()
	control_focus.release_focus()
	line_edit.grab_focus()
	is_lockpick_started = false
	# end unlocking sound


func _on_lockpick_timer_timeout() -> void:
	end_lockpick()


func _on_line_edit_text_submitted(new_text: String) -> void:
	new_text = new_text.to_lower()
	if new_text == full_word:
		success()
	else:
		failure()
		


func _on_success_timer_timeout() -> void:
	queue_free()
