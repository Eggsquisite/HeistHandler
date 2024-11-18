extends CenterContainer

@onready var full_word_container: HBoxContainer = $"VBoxContainer/Full Word Container"
@onready var line_edit: LineEdit = $VBoxContainer/LineEdit

var letter_node = preload("res://scenes/letter/letter.tscn")

var full_word: String
var letter_index: int
var index_array: Array[int] = []
var letter_containers: Array[Node] = []
var letter_array: Array[String] = []

var is_game_started: bool = false
var tries: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and !is_game_started:
		start_game(2)
	
	if Input.is_action_just_pressed("sneak"):
		end_game()
	
	if Input.is_action_just_pressed("switch_focus") and is_game_started:
		if !line_edit.has_focus():
			print("line_edit focus:%s" % line_edit.has_focus())
			line_edit.grab_focus()
			print("switching focus to line_edit")
		else:
			letter_containers[0].grab_focus()
			print("switching focus to letter")


func start_game(difficulty: int) -> void:
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
		index_array.remove_at(letter_index)
		letter_containers[letter_index].hide_letter()
	
	index_array.clear()


func setup_line_edit(diff: int) -> void:
	line_edit.grab_focus()
	line_edit.max_length = diff + 3
	
	
func end_game() -> void:
	is_game_started = false
	line_edit.hide()
	line_edit.show()
	index_array.clear()
	self.hide()
	# queue_free()


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text == full_word:
		print("Hooray! Correct word!")
		end_game()
	else:
		print("Boo! Wrong word!")
		line_edit.clear()
