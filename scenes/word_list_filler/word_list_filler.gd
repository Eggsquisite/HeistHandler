extends Node2D


const EASY_PATH: String = "res://words/words_easy.txt"


func _ready() -> void:
	update_easy_list()


func update_easy_list() -> void:
	var file: FileAccess = FileAccess.open(EASY_PATH, FileAccess.READ)
	
	var word_lists: WordLists = WordLists.new()
	
	if file:
		var list = file.get_as_text().split(" ", true)
		
		for word in list:
			word_lists.add_words(word, 1)
	
	file.close()
	ResourceSaver.save(word_lists, "res://resources/word_list_easy.tres")
