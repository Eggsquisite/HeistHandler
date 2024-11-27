extends Interactable

var coin = preload("res://scenes/coin_pickup/coin_pickup.tscn")

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var word_game: CenterContainer = $WordGame
@onready var chest_sprite: Sprite2D = $ChestSprite
@onready var chest_anim: AnimationPlayer = $ChestAnimationPlayer
@onready var coin_spawner: Node2D = $CoinSpawner

var unlocked: bool = false
var coin_pos: Vector2
@export_enum("copper", "silver") var coin_type: String = "copper"
@export var coin_amt: int = 1
@export var coin_range: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact() -> void:
	if word_game != null:
		word_game.start_minigame_timer(difficulty, time_to_pick, mult_to_pick)
		SignalManager.word_game_finished.connect(unlock_chest)
		SignalManager.letter_lockpicked.connect(letter_lockpicked)
	
	await SignalManager.word_game_finished


func letter_lockpicked() -> void:
	chest_anim.play("lockpicked")


func unlock_chest(flag: int) -> void:
	SignalManager.word_game_finished.disconnect(unlock_chest)
	SignalManager.letter_lockpicked.disconnect(letter_lockpicked)
	if flag == 2: # Paused game
		return
	elif flag == 1: # Lock unlocked
		chest_anim.stop()
		chest_anim.play("unlocked")
		spawn_coins()
		# SignalManager.chest_unlocked.emit(self.global_position, coin_type)
	interaction_area.queue_free()


func spawn_coins() -> void:
	var tmp_pos = to_local(coin_spawner.global_position)
	for i in range(coin_amt):
		var c = coin.instantiate()
		#coin_pos = Vector2(
			#randf_range(tmp_pos.x - coin_range, tmp_pos.x + coin_range),
			#randf_range(tmp_pos.y - coin_range, tmp_pos.y + coin_range)
		#)
		tmp_pos = Vector2(
			randf_range(-coin_range, coin_range),
			randf_range(-coin_range, coin_range)
		)
		coin_spawner.add_child(c)
		c.setup_coin(coin_type, true)
		c.set_move_location(tmp_pos)
