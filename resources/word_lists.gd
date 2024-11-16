extends Resource


class_name WordLists


@export var word_list_easy: Array[String]
@export var word_list_med: Array[String]
@export var word_list_hard: Array[String]


func add_words(word: String, difficulty: int) -> void:
	word = word.replace('\n', '')
	match difficulty:
		1:
			word_list_easy.append(word)
		2:
			word_list_med.append(word)
		3:
			word_list_hard.append(word)
	

func get_words(difficulty: int) -> Array[String]:
	match difficulty:
		1:
			return word_list_easy
		2:
			return word_list_med
		3:
			return word_list_hard
	return word_list_easy
	
