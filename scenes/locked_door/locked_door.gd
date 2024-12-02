extends Interactable

@onready var word_game: CenterContainer = $WordGame
@onready var door_anim: AnimationPlayer = $DoorAnim
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var lock: Sprite2D = $Lock
@onready var coll: CollisionShape2D = $StaticBody2D/Coll

var failed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coll.disabled = false
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact() -> void:
	if word_game != null:
		word_game.start_minigame_timer(difficulty, time_to_pick, mult_to_pick)
		SignalManager.word_game_finished.connect(unlock_door)
	
	await SignalManager.word_game_finished


func unlock_door(success: int) -> void:
	SignalManager.word_game_finished.disconnect(unlock_door)
	if success == 2: # Paused game
		return
	elif success == 1: # Lock unlocked
		door_anim.play("unlock")
		coll.disabled = true
		interaction_area.queue_free()
	elif success == 0: # Lock broken
		failed = true
