extends Node

signal word_game_started
signal word_game_finished(flag: int)
signal letter_lockpicked

signal on_loot_pickup(loot: int)
signal on_loot_updated(loot: int)

signal on_player_hit
