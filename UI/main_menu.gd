extends Control

@onready var arrow: Label = $Arrow
@onready var play_button: Button =$Menu/Play
@onready var rules_button: Button = $Menu/Rules
@onready var exit_button: Button = $Menu/Exit

var buttons: Array[Button] = []

func _ready() -> void:
	buttons = [play_button, rules_button, exit_button]

	for i in buttons.size():
		buttons[i].focus_entered.connect(_on_button_focused.bind(buttons[i]))
		# link up/down neighbors so ui_up/ui_down cycles between them
		buttons[i].focus_neighbor_top = buttons[(i - 1 + buttons.size()) % buttons.size()].get_path()
		buttons[i].focus_neighbor_bottom = buttons[(i + 1) % buttons.size()].get_path()

	play_button.grab_focus()  # start with first button focused

func _on_button_focused(button: Button) -> void:
	arrow.position = button.position + Vector2(-40, button.size.y / 2 - arrow.size.y / 2)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file('res://main.tscn')

func _on_rules_pressed() -> void:
	print("rules")

func _on_exit_pressed() -> void:
	get_tree().quit()
