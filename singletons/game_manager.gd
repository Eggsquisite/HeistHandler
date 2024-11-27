extends Node


var guards_alerted: int = 0
var alert_began: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_guard_alert.connect(guard_alerted)
	SignalManager.on_guard_lost.connect(guard_lost)
	SignalManager.on_game_over.connect(game_over)


func guard_alerted() -> void:
	if !alert_began:
		alert_began = true
		SignalManager.on_alert_start.emit() # On first alert status, start alarm 
	guards_alerted += 1


func guard_lost() -> void:
	guards_alerted -= 1
	if alert_began and guards_alerted == 0:
		SignalManager.on_alert_end.emit() # if no remaining guards alerted, end alarm


func game_over() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		e.set_process(false)
