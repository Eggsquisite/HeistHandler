extends CenterContainer

@onready var full_word_container: HBoxContainer = $"Control/ColorRect/VBoxContainer/Full Word Container"
@onready var lockpick_tries_container: HBoxContainer = $Control/ColorRect/LockpickTriesContainer
@onready var line_edit: LineEdit = $Control/ColorRect/VBoxContainer/LineEdit
@onready var lockpick_timer: Timer = $LockpickTimer
@onready var finished_timer: Timer = $FinishedTimer
@onready var start_timer: Timer = $StartTimer
@onready var label_timer: Timer = $LabelTimer
@onready var color_rect: ColorRect = $ColorRect
@onready var lock_status: Label = $Control/ColorRect/VBoxContainer/LockStatus
@onready var used_words: VBoxContainer = $Control/ColorRect2/MarginContainer/UsedWordsContainer
@onready var instructions: Label = $Control/ColorRect/VBoxContainer/Instructions
@onready var lockpick_bar: TextureProgressBar = $Control/ColorRect/VBoxContainer/Control/LockpickProgressBar
@onready var sound: AudioStreamPlayer2D = $Sound

@export_enum("Chest", "Door") var unlock_type: String = "Chest"

var letter_node = preload("res://scenes/letter/letter.tscn")
var lockpick_tries = preload("res://scenes/lockpick_tries/lockpick_tries.tscn")
var used_word_label = preload("res://scenes/used_word/used_word.tscn")
var word_game = preload("res://scenes/word_game/word_game.tscn")

var full_word: String = ''
var letter_index: int
var index_array: Array[int] = []
var letter_containers: Array[Node] = []
var letter_array: Array[String] = []

var tries_left: int = 0
var lockpick_count: int = 0
var lockpick_max: int = 0
var lockpick_current: int = 0
var letter_focus: Control
var is_game_started: bool = false
var is_lockpicking: bool = false
var is_lock_picked: bool = false
var is_lock_broken: bool = false
var is_paused: bool = false
var is_interacting: bool = false
var letter_covers: int
var lp_time: float = 0.0

var _max_tries: int
var _difficulty: String
var _time_to_pick: float
var _multiplier_to_pick: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	SignalManager.on_player_hit.connect(end_minigame)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("lockpick") and is_interacting:
		letter_focus = get_viewport().gui_get_focus_owner()
		if letter_focus != null and letter_focus != line_edit:
			begin_lockpick()
	
	if Input.is_action_just_pressed("escape") and !check_lock_finished():
		end_minigame(0)
	
	if is_lockpicking:
		lp_time += delta
		lockpick_bar.value = lp_time


func start_minigame_timer(diff: String, pick_time: float, pick_mult: float) -> void:
	# Just to avoid "e" being in LineEdit on start because line_edit.clear not working?
	start_timer.start()
	
	# If starting game for the first time, init interactable variables
	if !is_game_started:
		setup_variables(diff, pick_time, pick_mult)
		lockpick_tries_container.update_lockpick_amt(lockpick_max)


func start_minigame() -> void:
	if is_paused:
		resume_minigame()
		return

	self.show()
	is_game_started = true
	is_interacting = true
	SignalManager.word_game_started.emit()
	
	full_word = ""
	full_word = WordManager.get_random_word(_difficulty)
	for letter in full_word:
		letter_array.append(letter)

	print(full_word)
	for letter in letter_array:
		var letter_instance = letter_node.instantiate()
		full_word_container.add_child(letter_instance)
		
		letter_instance.get_letter().text = letter
		letter_containers.append(letter_instance)
	
	setup_line_edit(true)
	update_lock_label()
	randomize_letter(letter_containers.size() - 1)
	start_letter_focus()


func resume_minigame() -> void:
	SignalManager.word_game_started.emit()
	self.show()
	is_paused = false
	is_interacting = true
	
	for n in letter_containers:
		n.reenable_focus()

	update_lock_label()
	start_letter_focus()
	setup_line_edit(true)


func start_letter_focus() -> void:
	# grab focus of the first hidden letter
	for n in letter_containers:
		if n.get_is_hidden() and !n.get_no_more_reveals():
			n.set_focus()
			break
		line_edit.grab_focus()


func randomize_letter(size: int) -> void:
	for n in range(0, size + 1, 1):
		index_array.append(n)
	
	# Get a random index, then remove that index from index_array to prevent dupes
	for n in range(0, letter_covers, 1):
		letter_index = index_array.pick_random()
		index_array.erase(letter_index)
		letter_containers[letter_index].hide_letter()
	
	index_array.clear()


func setup_variables(diff: String, pick_time: float, pick_mult: float) -> void:
	_difficulty = diff
	_time_to_pick = pick_time
	_multiplier_to_pick = pick_mult
	lockpick_bar.hide()
	lockpick_bar.value = 0.0
	
	match _difficulty:
		"easy":
			letter_covers = 2
			lockpick_max = 1
			_max_tries = 5
			tries_left = _max_tries
			lockpick_current = lockpick_max
		"medium":
			letter_covers = 3
			lockpick_max = 2
			_max_tries = 5
			tries_left = _max_tries
			lockpick_current = lockpick_max
		"medium-hard":
			letter_covers = 4
			lockpick_max = 3
			_max_tries = 5
			tries_left = _max_tries
			lockpick_current = lockpick_max
		"hard":
			letter_covers = 5
			lockpick_max = 3
			_max_tries = 6
			tries_left = _max_tries
			lockpick_current = lockpick_max


func setup_line_edit(flag: bool) -> void:
	if flag:
		line_edit.focus_mode = Control.FOCUS_ALL
		line_edit.mouse_filter = Control.MOUSE_FILTER_STOP
		line_edit.clear()
		# line_edit.grab_focus()
		line_edit.editable = true
		line_edit.max_length = letter_array.size()
	else:
		line_edit.focus_mode = Control.FOCUS_NONE
		line_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE


func update_lock_label() -> void:
	if is_lock_picked:
		lock_status.text = "Unlocked!"
	elif tries_left > 0:
		lock_status.text = "%s Guesses" % tries_left
	elif tries_left <= 0:
		if unlock_type == "Chest":
			lock_status.text = "Lock broken!"
		elif unlock_type == "Door":
			lock_status.text = "Try again!"


func begin_lockpick() -> void:
	if is_lockpicking:
		return
	
	is_lockpicking = true
	lockpick_count += 1
	lockpick_bar.show()
	
	var lp_time: float
	if lockpick_count == 1:
		lp_time = _time_to_pick
	else:
		lp_time = _time_to_pick + (
			_time_to_pick * (_multiplier_to_pick - 1) * (lockpick_count - 1)
			)
	lockpick_bar.max_value = lp_time
	print("lp time: %s" % lp_time)
	
	setup_line_edit(false)
	lockpick_timer.start(lp_time)
	letter_focus.begin_lockpick(lp_time)
	
	# Prevent surrounding nodes from being lockpicked/selected
	for n in letter_containers:
		if n != letter_focus:
			n.disable_focus()
	# play unlocking sound


func end_lockpick() -> void:
	is_lockpicking = false
	letter_focus.show_letter(sound)
	letter_focus.release_focus()
	
	reset_lockpick_bar()
	setup_line_edit(true)
	line_edit.grab_focus()
	lockpick_current -= 1
	lockpick_tries_container.update_lockpick_amt(lockpick_current)
	SoundManager.play_clip(sound, SoundManager.SOUND_UNLOCK)
	SignalManager.letter_lockpicked.emit()
	
	for n in letter_containers:
		if n != letter_focus:
			n.reenable_focus()
	
	if lockpick_count >= lockpick_max:
		for n in letter_containers:
			n.no_more_reveal()
	# end unlocking sound


func success() -> void:
	if is_lock_picked:
		return
	
	is_lock_picked = true 
	update_lock_label()
	start_finished_timer()
	# play unlock sound
	SoundManager.play_clip(sound, SoundManager.SOUND_UNLOCK)
	SignalManager.letter_lockpicked.emit() # plays chest anim


func failure() -> void:
	tries_left -= 1
	line_edit.clear()
	lock_status.text = "Wrong Guess!"
	label_timer.start()
	SignalManager.letter_lockpicked.emit() # plays chest anim
	
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


func end_minigame(_lives: int) -> void:
	if !is_interacting: # since now connected to on_player_hit signal, need check
		return
	
	# Lock picked or broken, delete minigame
	if check_lock_finished():
		# To check if chest is unlock/locked
		if is_lock_picked:
			SignalManager.word_game_finished.emit(1)
			if unlock_type == "Chest":
				SoundManager.play_clip(sound, SoundManager.SOUND_CHEST_OPEN)
		elif is_lock_broken:
			SignalManager.word_game_finished.emit(0)
			if unlock_type == "Chest":
				queue_free()
			elif unlock_type == "Door":
				reset_game()
				return
	
	# Pause game
	SignalManager.word_game_finished.emit(2)
	self.hide()
	line_edit.clear()

	is_paused = true
	is_interacting = false
	line_edit.editable = false
	reset_lockpick_bar()
	
	if is_lockpicking:
		lockpick_count -= 1
		is_lockpicking = false
		lockpick_timer.stop()


func reset_game() -> void:
	self.hide()
	line_edit.clear()
	letter_array.clear()
	letter_containers.clear()
	is_interacting = false
	is_lock_broken = false
	line_edit.editable = false

	lockpick_count = 0
	tries_left = _max_tries
	lockpick_current = lockpick_max
	
	update_lock_label()
	reset_lockpick_bar()
	lockpick_tries_container.update_lockpick_amt(lockpick_max)
	
	for n in used_words.get_children():
		if !n.name.contains("Title"):
			n.queue_free()
	for n in full_word_container.get_children():
		n.queue_free()


func reset_lockpick_bar() -> void:
	lockpick_bar.hide()
	lp_time = 0.0
	lockpick_bar.value = 0.0


func compare_letters(new_text: String) -> void:
	var new: Array[String]
	var old: Array[String]
	
	for char in new_text:
		new.push_back(char)
	for char in full_word:
		old.push_back(char)
	
	for i in range(0, new.size()):
		if new[i] == old[i]:
			letter_containers[i].show_letter(sound)
			
			# ADD if want to match unlocks
			#if lockpick_current > 0:
				#lockpick_current -= 1
				#lockpick_tries_container.update_lockpick_amt(lockpick_current)


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
		var instance = used_word_label.instantiate()
		instance.text = new_text
		used_words.add_child(instance)
		# REMOVE if want to take out letter compare unlocks
		compare_letters(new_text)


func _on_finished_timer_timeout() -> void:
	end_minigame(0)


func _on_start_timer_timeout() -> void:
	start_minigame()


func _on_label_timer_timeout() -> void:
	update_lock_label()


func _on_line_edit_focus_exited() -> void:
	pass
	# instructions.visible = true


func _on_line_edit_focus_entered() -> void:
	pass
	# instructions.visible = false
