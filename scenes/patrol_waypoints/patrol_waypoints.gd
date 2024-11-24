extends Node2D

var waypoints: Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tmp = get_children()
	for t in tmp:
		waypoints.append(t.global_position)


func get_waypoints() -> Array[Vector2]:
	return waypoints
