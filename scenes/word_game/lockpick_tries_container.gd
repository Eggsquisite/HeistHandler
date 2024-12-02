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
	
	#if lockpicks != []:
		#for i in range(0, lockpicks.size()):
			#lockpicks[i].queue_free()
	#
	## Initialize lockpick UI
	#for i in range(0, amt):
		#var instance = lockpick_tries.instantiate()
		#lockpicks.append(instance)
		#add_child(instance)
#
	#lockpick_amt = amt - 1
	#lockpick_total = lockpick_amt


func remove_lockpick() -> void:
	lockpicks[lockpick_amt].hide()
	lockpick_amt -= 1
