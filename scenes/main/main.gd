extends Control


var displaying: bool = false
@onready var cr_rules: ColorRect = $CRRules
@onready var cr_credits: ColorRect = $CRCredits

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cr_rules.hide()
	cr_credits.hide()
	SignalManager.on_quit_button_pressed.connect(quit)
	SignalManager.on_rules_button_pressed.connect(display_rules)
	SignalManager.on_credits_button_pressed.connect(display_credits)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and displaying:
		displaying = false
		cr_rules.hide()
		cr_credits.hide()

func display_rules() -> void:
	displaying = true
	cr_rules.show()


func display_credits() -> void:
	displaying = true
	cr_credits.show()


func quit() -> void:
	get_tree().quit()
