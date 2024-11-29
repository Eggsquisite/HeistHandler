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


func get_random_word(difficulty: String) -> String:
	match difficulty:
		"easy":
			if _word_list_easy != []:
				return _word_list_easy.pick_random()
		"medium":
			if _word_list_med != []:
				return _word_list_med.pick_random()
		"medium-hard":
			if _word_list_med != []:
				return _word_list_med.pick_random()
		"hard":
			if _word_list_hard != []:
				return _word_list_hard.pick_random()
	return 'debug'
