extends Node

signal word_game_started
signal word_game_finished(flag: int)
signal letter_lockpicked

signal on_loot_pickup(loot: int)
signal on_loot_updated(loot: int)

signal on_game_over
signal on_player_hit(lives: int)
signal on_level_started(lives: int)
signal on_level_complete
signal on_score_end(loot: int, elapsed_time: float, level: String)
signal on_rank_set(rank: int, total_loot: int)

signal on_guard_alert
signal on_guard_lost
signal on_alert_start
signal on_alert_end
