extends HBoxContainer


var lockpick_tries = preload("res://scenes/lockpick_tries/lockpick_tries.tscn")
var lockpicks: Array[Control] = []
var lockpick_amt: int

func setup_lockpick_amt(diff: int) -> void:
	# Initialize lockpick UI
	for i in range(0, diff):
		var instance = lockpick_tries.instantiate()
		lockpicks.append(instance)
		add_child(instance)
	
	print(lockpicks.size())
	lockpick_amt = lockpicks.size() - 1


func remove_lockpick() -> void:
	print("reducing lockpick UI")
	lockpicks[lockpick_amt].hide()
	lockpick_amt -= 1
