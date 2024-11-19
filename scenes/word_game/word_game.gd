extends CenterContainer

@onready var full_word_container: HBoxContainer = $"Control/ColorRect/VBoxContainer/Full Word Container"
@onready var line_edit: LineEdit = $Control/ColorRect/VBoxContainer/LineEdit
@onready var lockpick_timer: Timer = $LockpickTimer
@onready var color_rect: ColorRect = $ColorRect

var letter_node = preload("res://scenes/letter/letter.tscn")

var full_word: String = ''
var letter_index: int
var index_array: Array[int] = []
var letter_containers: Array[Node] = []
var letter_array: Array[String] = []

var is_game_started: bool = false
var is_lockpick_started: bool = false
var control_focus: Control

var tries: int = 0
@export var tries_remaining: int = 3
@export var time_to_pick: float = 1
@export var multiplier_to_pick: float = 1.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# color_rect.set_size(Vector2(100, 100))
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and !is_game_started:
		start_minigame(2)
	
	if Input.is_action_just_pressed("lockpick") and !is_lockpick_started:
		control_focus = get_viewport().gui_get_focus_owner()
		if control_focus != null and control_focus != line_edit:
			begin_lockpick()


func start_minigame(difficulty: int) -> void:
	tries = 0
	is_game_started = true
	setup_line_edit(difficulty)
	
	full_word = WordManager.get_random_word(difficulty)
	print(full_word)
	for letter in full_word:
		letter_array.append(letter)
	
	print(letter_array)
	for letter in letter_array:
		var letter_instance = letter_node.instantiate()
		full_word_container.add_child(letter_instance)
		
		letter_instance.get_letter().text = letter.capitalize()
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


func setup_line_edit(diff: int) -> void:
	line_edit.grab_focus()
	line_edit.max_length = diff + 3
	
	
func end_minigame() -> void:
	full_word = ''
	is_game_started = false
	is_lockpick_started = false
	index_array.clear()
	letter_array.clear()
	line_edit.hide()
	line_edit.show()
	self.hide()
	# queue_free()


func begin_lockpick() -> void:
	is_lockpick_started = true
	tries += 1
	control_focus.grab_focus()
	lockpick_timer.start(time_to_pick * (multiplier_to_pick * tries))
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
		print("Hooray! Correct word!")
		# play unlock sound
		end_minigame()
	else:
		print("Boo! Wrong word!")
		tries_remaining -= 1
		line_edit.clear()
		# play wrong word sound
		if tries_remaining <= 0:
			print("Lock broken!")
			# play lock broken sound
			end_minigame()
