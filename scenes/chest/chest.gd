extends Interactable

var coin = preload("res://scenes/coin_pickup/coin_pickup.tscn")

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var word_game: CenterContainer = $WordGame
@onready var chest_sprite: Sprite2D = $ChestSprite
@onready var chest_anim: AnimationPlayer = $ChestAnimationPlayer
@onready var coin_spawner: Node2D = $CoinSpawner
@onready var coin_timer: Timer = $CoinTimer

var unlocked: bool = false
var coin_pos: Vector2
var coin_count: int = 0
@export_enum("copper", "silver") var coin_type: String = "copper"
@export var coin_amt: int = 1
@export var coin_range: float = 25.0

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
	interaction_area.queue_free()


func spawn_coins() -> void:
	var tmp_pos = to_local(coin_spawner.global_position)
	for i in range(0, coin_amt):
		var c = coin.instantiate()
		tmp_pos = Vector2(
			randf_range(-coin_range, coin_range),
			randf_range(10, coin_range * 2)
		)
		coin_spawner.add_child(c)
		var tmp = to_local(coin_spawner.global_position)
		var tmp_spawn = Vector2(
			randf_range(tmp.x - 2, tmp.x + 2),
			0 #lol
		)
		c.setup_coin(coin_type, true)
		c.move_to_location(tmp_spawn, tmp_pos)


func get_loot_amt() -> int:
	if coin_type == "copper":
		return coin_amt
	elif coin_type == "silver":
		return coin_amt * 5
	return 0


func _on_chest_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "unlocked":
		spawn_coins()
		# coin_timer.start()



func _on_coin_timer_timeout() -> void:
	if coin_count < coin_amt:
		spawn_coins()
		coin_count += 1
	else:
		coin_timer.stop()
