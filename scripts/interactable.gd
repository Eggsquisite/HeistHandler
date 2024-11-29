extends Node2D


class_name Interactable

# @export var max_tries: int = 3
@export_enum("easy", "medium", "medium-hard", "hard") var difficulty: String = "easy"
@export var time_to_pick: float = 1
@export var mult_to_pick: float = 1.15
