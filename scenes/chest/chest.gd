extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var word_game: CenterContainer = $WordGame
@onready var open_chest: Sprite2D = $OpenChest
@onready var locked_chest: Sprite2D = $LockedChest

var unlocked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact() -> void:
	if word_game != null:
		word_game.start_minigame()
		SignalManager.word_game_finished.connect(unlock_chest)
	
	await SignalManager.word_game_finished


func unlock_chest(unlock_flag: bool) -> void:
	SignalManager.word_game_finished.disconnect(unlock_chest)
	if unlock_flag: 
		locked_chest.hide()
		open_chest.show()
