extends TextureProgressBar


const MAX_VALUE = 100

var detection: float = 0 : set = _set_detection
var alert: bool = false
var q_mark = preload("res://assets/ui/question_mark.png")
var q_mark_fill = preload("res://assets/ui/question_mark_fill.png")
var e_mark = preload("res://assets/ui/exclamation_mark.png")
var e_mark_fill = preload("res://assets/ui/exclamation_mark_fill.png")

func _ready() -> void:
	max_value = MAX_VALUE
	value = min_value
	texture_under = q_mark
	texture_progress = q_mark_fill
	self.hide()
	


func _set_detection(new_value):
	if new_value < 0:
		new_value = 0
	
	new_value = min(max_value, new_value)
	detection = new_value
	value = detection
	if detection > 0:
		self.show()
	elif detection <= 0:
		self.hide()
	
	if detection >= max_value and !alert:
		alert = true
		texture_under = e_mark
		texture_progress = e_mark_fill
	elif detection <= min_value and alert:
		alert = false
		texture_under = q_mark
		texture_progress = q_mark_fill


func _get_is_alert() -> bool:
	return alert
