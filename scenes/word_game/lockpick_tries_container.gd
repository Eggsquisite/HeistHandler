extends HBoxContainer


var lockpick_tries = preload("res://scenes/lockpick_tries/lockpick_tries.tscn")
var lockpicks: Array[Control] = []
var lockpick_amt: int

func setup_lockpick_amt(amt: int) -> void:
	# Initialize lockpick UI
	for i in range(0, amt):
		var instance = lockpick_tries.instantiate()
		lockpicks.append(instance)
		add_child(instance)

	lockpick_amt = amt - 1


func remove_lockpick() -> void:
	lockpicks[lockpick_amt].hide()
	lockpick_amt -= 1
