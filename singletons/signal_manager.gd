extends Node

signal word_game_started
signal word_game_finished(flag: int)
signal letter_lockpicked

signal on_loot_pickup(loot: int)
signal on_loot_updated(loot: int)

signal on_player_hit(lives: int)
signal on_player_started(lives: int)

signal on_level_started(total_loot: int)
signal on_level_complete
signal on_score_end(loot: int, elapsed_time: float, level: String)
signal on_rank_set(rank: int)
signal on_game_over

signal on_play_button_pressed
signal on_quit_button_pressed
signal on_rules_button_pressed
signal on_credits_button_pressed

signal on_leave_start
signal on_leave_end

signal on_guard_alert
signal on_guard_lost
signal on_alert_start
signal on_alert_end

signal on_pickup_sound
