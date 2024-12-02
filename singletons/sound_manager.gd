
extends Node


const SOUND_HURT = "hurt"
const SOUND_PICKUP = "pickup"
const SOUND_SLASH = "slash"
const SOUND_UNLOCK = "unlock"
const SOUND_CHEST_OPEN = "chest_open"
const SOUND_LVL_END = "lvl_end"
const SOUND_MUSIC1 = "music1"
const SOUND_MUSIC2 = "music2"


var SOUNDS: Dictionary = {
	SOUND_PICKUP: preload("res://assets/sounds/sfx/166184__drminky__retro-coin-collect.wav"),
	SOUND_HURT: preload("res://assets/sounds/sfx/44429__thecheeseman__hurt2.wav"),
	SOUND_SLASH: preload("res://assets/sounds/sfx/616481__deleted_user_13668154__swordslashwav.wav"),
	SOUND_UNLOCK: preload("res://assets/sounds/sfx/512139__beezlefm__unlock-sound.wav"),
	SOUND_CHEST_OPEN: preload("res://assets/sounds/sfx/puff-of-magic-treasure-chest-light-smartsound-fx-1-00-04.mp3"),
	SOUND_LVL_END: preload("res://assets/sounds/sfx/level-up-retro-video-game-soundroll-1-00-02.mp3"),
}


func play_clip(player: AudioStreamPlayer2D, clip_key: String) -> void:
	if SOUNDS.has(clip_key) == false:
		return
	player.stream = SOUNDS[clip_key]
	player.play()
