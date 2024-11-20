extends CenterContainer

@onready var full_word_container: HBoxContainer = $"Control/ColorRect/VBoxContainer/Full Word Container"
@onready var line_edit: LineEdit = $Control/ColorRect/VBoxContainer/LineEdit
@onready var lockpick_timer: Timer = $LockpickTimer
@onready var finished_timer: Timer = $FinishedTimer
@onready var start_timer: Timer = $StartTimer
@onready var label_timer: Timer = $LabelTimer
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
var is_lockpicking: bool = false
var is_lock_picked: bool = false
var is_lock_broken: bool = false
var is_paused: bool = false
var is_interacting: bool = false
var letter_covers: int

var _max_tries: int
var _difficulty: int
var _time_to_pick: float
var _multiplier_to_pick: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("lockpick") and is_interacting:
		control_focus = get_viewport().gui_get_focus_owner()
		if control_focus != null and control_focus != line_edit:
			begin_lockpick()
	
	if Input.is_action_just_pressed("escape") and is_interacting and !check_lock_finished():
		end_minigame()


func start_minigame_timer(tries: int, diff: int, pick_time: float, pick_mult: float) -> void:
	# Just to avoid "e" being in LineEdit on start because line_edit.clear not working?
	start_timer.start()
	
	# If starting game for the first time, init interactable variables
	if !is_game_started:
		setup_variables(tries, diff, pick_time, pick_mult)


func start_minigame() -> void:
	if is_paused:
		resume_minigame()
		return
	
	self.show()
	is_game_started = true
	is_interacting = true
	SignalManager.word_game_started.emit()
	
	full_word = WordManager.get_random_word(_difficulty)
	for letter in full_word:
		letter_array.append(letter)

	print(full_word)
	for letter in letter_array:
		var letter_instance = letter_node.instantiate()
		full_word_container.add_child(letter_instance)
		
		letter_instance.get_letter().text = letter
		letter_containers.append(letter_instance)

	setup_line_edit()
	update_lock_label()
	randomize_letter(_difficulty, letter_containers.size() - 1)


func resume_minigame() -> void:
	SignalManager.word_game_started.emit()
	self.show()
	is_paused = false
	is_interacting = true
	update_lock_label()
	setup_line_edit()


func randomize_letter(difficulty: int, size: int) -> void:
	for n in range(0, size + 1, 1):
		index_array.append(n)
	
	# Get a random index, then remove that index from index_array to prevent dupes
	for n in range(0, letter_covers, 1):
		letter_index = index_array.pick_random()
		index_array.erase(letter_index)
		letter_containers[letter_index].hide_letter()
	
	index_array.clear()


func setup_variables(tries: int, diff: int, pick_time: float, pick_mult: float) -> void:
	_max_tries = tries
	_difficulty = diff
	_time_to_pick = pick_time
	_multiplier_to_pick = pick_mult
	
	tries_left = _max_tries
	letter_covers = _difficulty + 1


func setup_line_edit() -> void:
	line_edit.editable = true
	line_edit.clear()
	line_edit.grab_focus()
	line_edit.max_length = letter_array.size()


func update_lock_label() -> void:
	if is_lock_picked:
		lock_status.text = "Unlocked!"
	elif tries_left > 0:
		lock_status.text = "%s tries left!" % tries_left
	elif tries_left <= 0:
		lock_status.text = "Lock is broken!"


func begin_lockpick() -> void:
	if is_lockpicking:
		return
	
	is_lockpicking = true
	lockpick_count += 1
	
	control_focus.grab_focus()
	line_edit.editable = false
	lockpick_timer.start(_time_to_pick * (_multiplier_to_pick * lockpick_count))
	# play unlocking sound


func end_lockpick() -> void:
	control_focus.show_letter()
	control_focus.release_focus()
	is_lockpicking = false
	
	line_edit.editable = true
	line_edit.grab_focus()
	
	if lockpick_count >= letter_covers - 1:
		for n in letter_containers:
			n.no_more_reveal()
	# end unlocking sound


func success() -> void:
	if is_lock_picked:
		return
	
	is_lock_picked = true 
	update_lock_label()
	start_finished_timer()
	# reward player
	# play unlock sound


func failure() -> void:
	tries_left -= 1
	line_edit.clear()
	lock_status.text = "Wrong Word!"
	label_timer.start()
	
	if tries_left <= 0:
		# play lock broken sound
		is_lock_broken = true
		label_timer.stop()
		update_lock_label()
		start_finished_timer()


func start_finished_timer() -> void:
	if finished_timer.time_left <= 0:
		finished_timer.start()
	
	line_edit.editable = false
	for n in full_word_container.get_children():
		n.word_finished()


func end_minigame() -> void:
	# Lock picked or broken, delete minigame
	if check_lock_finished():
		# To check if chest is unlock/locked
		if is_lock_picked:
			SignalManager.word_game_finished.emit(true)
		elif is_lock_broken:
			SignalManager.word_game_finished.emit(false)
		queue_free()
	
	# Pause game
	SignalManager.word_game_finished.emit(false)
	self.hide()
	line_edit.clear()

	is_paused = true
	is_interacting = false
	line_edit.editable = false


func check_lock_finished() -> bool:
	if is_lock_broken or is_lock_picked:
		return true
	else:
		return false


func _on_lockpick_timer_timeout() -> void:
	end_lockpick()


func _on_line_edit_text_submitted(new_text: String) -> void:
	new_text = new_text.to_lower()
	if new_text == full_word:
		success()
	else:
		failure()


func _on_complete_timer_timeout() -> void:
	end_minigame()


func _on_start_timer_timeout() -> void:
	start_minigame()


func _on_label_timer_timeout() -> void:
	update_lock_label()
