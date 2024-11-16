extends Node


var _word_list_easy: Array[String] = []
var _word_list_med: Array[String] = []
var _word_list_hard: Array[String] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var word_lists: WordLists = load("res://resources/word_lists.tres")
	
	for word in word_lists.get_words(1):
		_word_list_easy.append(word)
	for word in word_lists.get_words(2):
		_word_list_med.append(word)
	for word in word_lists.get_words(3):
		_word_list_hard.append(word)



func get_random_word(difficulty: int) -> String:
	match difficulty:
		1:
			if _word_list_easy != []:
				return _word_list_easy.pick_random()
		2:
			if _word_list_med != []:
				return _word_list_med.pick_random()
		3:
			if _word_list_hard != []:
				return _word_list_hard.pick_random()
	return 'debug'
