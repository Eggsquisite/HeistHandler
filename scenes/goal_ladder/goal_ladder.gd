extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var progress_bar: TextureProgressBar = $ProgressBar
var leaving: bool = false
var progress: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progress_bar.value = 0
	interaction_area.interact = Callable(self, "_on_interact")
	SignalManager.on_player_hit.connect(end_leave)


func _process(delta: float) -> void:
	if leaving:
		if Input.is_action_just_released("interact"):
			end_leave()
		progress += delta
		progress_bar.value = progress


func _on_interact() -> void:
	leaving = true
	progress_bar.show()
	SignalManager.on_leave_start.emit()
	
	await SignalManager.on_leave_end


func end_leave() -> void:
	progress_bar.hide()
	leaving = false
	progress = 0.0
	progress_bar.value = 0
	
	SignalManager.on_leave_end.emit(0)


func finish_leave() -> void:
	progress_bar.hide()
	leaving = false
	progress = 0.0
	progress_bar.value = 0
	
	SignalManager.on_leave_end.emit()
	SignalManager.on_level_complete.emit()


func _on_progress_bar_value_changed(value: float) -> void:
	if value == progress_bar.max_value:
		finish_leave()
