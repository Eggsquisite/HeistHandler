extends CenterContainer

@onready var full_word_container: HBoxContainer = $"VBoxContainer/Full Word Container"
@onready var line_edit: LineEdit = $VBoxContainer/LineEdit

var letter_node = preload("res://scenes/letter/letter.tscn")

var full_word: String
var letter_index: int
var index_array: Array[int] = []
var label_array: Array[Node] = []
var letter_array: Array[String] = []
var is_game_started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func start_game(difficulty: int) -> void:
	is_game_started = true
	line_edit.grab_focus()
	
	full_word = WordManager.get_random_word(difficulty)
	print(full_word)
	for letter in full_word:
		letter_array.append(letter)
	
	print(letter_array)
	for letter in letter_array:
		var letter_instance = letter_node.instantiate()
		full_word_container.add_child(letter_instance)
		
		letter_instance.get_letter().text = letter.capitalize()
		label_array.append(letter_instance)

	randomize_letter(2, label_array.size() - 1)


func randomize_letter(difficulty: int, size: int) -> void:
	for n in range(0, size + 1, 1):
		index_array.append(n)
	
	# Get a random index, then remove that index from index_array to prevent dupes
	for n in range(0, difficulty, 1):
		letter_index = index_array.pick_random()
		index_array.remove_at(letter_index)
		label_array[letter_index].hide_letter()
	
	index_array.clear()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and !is_game_started:
		start_game(1)
