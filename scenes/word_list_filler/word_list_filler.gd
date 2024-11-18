extends Node2D


const EASY_PATH: String = "res://words/words_easy.txt"
const MED_PATH: String = "res://words/words_med.txt"
const HARD_PATH: String = "res://words/words_hard.txt"


func _ready() -> void:
	# Create new Resource
	var word_lists: WordLists = WordLists.new()
	
	update_easy_list(word_lists)
	update_med_list(word_lists)
	update_hard_list(word_lists)
	ResourceSaver.save(word_lists, "res://resources/word_lists.tres")


func update_easy_list(wl: WordLists) -> void:
	var file: FileAccess = FileAccess.open(EASY_PATH, FileAccess.READ)
	
	if file:
		var list = file.get_as_text().split(' ', true)
		for word in list:
			wl.add_words(word, 1)
	file.close()


func update_med_list(wl: WordLists) -> void:
	var file: FileAccess = FileAccess.open(MED_PATH, FileAccess.READ)
	
	if file:
		var list = file.get_as_text().split(' ', true)
		for word in list:
			wl.add_words(word, 2)
	file.close()


func update_hard_list(wl: WordLists) -> void:
	var file: FileAccess = FileAccess.open(HARD_PATH, FileAccess.READ)
	
	if file:
		var list = file.get_as_text().split(' ', true)
		for word in list:
			wl.add_words(word, 3)
	file.close()
