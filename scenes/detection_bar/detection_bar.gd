extends TextureProgressBar


const MAX_VALUE = 100

var detection: float = 0 : set = _set_detection
var alert: bool = false

func _ready() -> void:
	max_value = MAX_VALUE
	value = min_value


func _set_detection(new_value):
	if new_value < 0:
		new_value = 0
	
	new_value = min(max_value, new_value)
	detection = new_value
	value = detection
	
	if detection >= max_value and !alert:
		alert = true
	elif detection <= min_value and alert:
		alert = false


func _get_is_alert() -> bool:
	return alert
