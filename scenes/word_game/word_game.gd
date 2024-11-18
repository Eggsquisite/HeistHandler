extends CenterContainer

@onready var full_word_container: HBoxContainer = $"VBoxContainer/Full Word Container"
@onready var line_edit: LineEdit = $VBoxContainer/LineEdit

var letter_node = preload("res://scenes/letter/letter.tscn")

var full_word: String
var letter_array: Array[String] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	full_word = WordManager.get_random_word(1)
	print(full_word)
	for letter in full_word:
		letter_array.append(letter)
	
	print(letter_array)
	for letter in letter_array:
		var letter_instance = letter_node.instantiate()
		letter_instance.get_child(0).text = letter.capitalize()
		full_word_container.add_child(letter_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
