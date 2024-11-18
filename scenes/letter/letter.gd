extends CenterContainer


@onready var letter: Label = $Letter
@onready var letter_cover: Sprite2D = $LetterCover


func get_letter() -> Label:
	return letter


func hide_letter() -> void:
	letter_cover.show()
