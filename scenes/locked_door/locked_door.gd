extends Interactable

@onready var word_game: CenterContainer = $WordGame
@onready var door_anim: AnimationPlayer = $DoorAnim
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var lock: Sprite2D = $Lock

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact() -> void:
	if word_game != null:
		word_game.start_minigame_timer(difficulty, time_to_pick, mult_to_pick)
		SignalManager.word_game_finished.connect(unlock_door)
	
	await SignalManager.word_game_finished


func unlock_door(flag: int) -> void:
	SignalManager.word_game_finished.disconnect(unlock_door)
	if flag == 2: # Paused game
		return
	elif flag == 1: # Lock unlocked
		door_anim.play("unlock")
	interaction_area.queue_free()
