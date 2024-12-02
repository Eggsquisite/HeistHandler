extends HBoxContainer


var lockpick_tries = preload("res://scenes/lockpick_tries/lockpick_tries.tscn")
var lockpicks: Array = []
var lockpick_amt: int
var lockpick_total: int


func _ready() -> void:
	lockpicks = get_children()
	for l in lockpicks:
		l.hide()


func update_lockpick_amt(amt: int) -> void:
	for i in range(lockpicks.size()):
		lockpicks[i].visible = amt > i
