extends Control

@onready var arrow: Label = $Arrow
@onready var play_button: Button = $Menu/Play
@onready var rules_button: Button = $Menu/Rules
@onready var exit_button: Button = $Menu/Exit

var buttons: Array[Button] = []
var arrow_base_pos: Vector2
var hover_tween: Tween

func _ready() -> void:
	arrow.pivot_offset = arrow.size / 2  # rotate around center, not top-left

	buttons = [play_button, rules_button, exit_button]

	for i in buttons.size():
		buttons[i].focus_entered.connect(_on_button_focused.bind(buttons[i]))
		buttons[i].focus_neighbor_top = buttons[(i - 1 + buttons.size()) % buttons.size()].get_path()
		buttons[i].focus_neighbor_bottom = buttons[(i + 1) % buttons.size()].get_path()

	play_button.grab_focus()

func _on_button_focused(button: Button) -> void:
	var global_target = button.global_position + Vector2(-40, button.size.y / 2 - arrow.size.y / 2)
	arrow_base_pos = get_global_transform().affine_inverse() * global_target
	arrow.position = arrow_base_pos
	_start_hover()

func _start_hover() -> void:
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.set_loops()
	hover_tween.tween_property(arrow, "position:x", arrow_base_pos.x - 8, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	hover_tween.tween_property(arrow, "position:x", arrow_base_pos.x + 8, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_jab_arrow()

func _jab_arrow() -> void:
	var focused = get_viewport().gui_get_focus_owner()
	if focused == null or not (focused is Button):
		return

	if hover_tween:
		hover_tween.kill()

	var jab_tween = create_tween()
	jab_tween.tween_property(arrow, "position:x", arrow_base_pos.x + 20, 0.1).set_trans(Tween.TRANS_SINE)
	jab_tween.tween_property(arrow, "position:x", arrow_base_pos.x, 0.1).set_trans(Tween.TRANS_SINE)
	jab_tween.tween_callback(func():
		focused.emit_signal("pressed")
		_start_hover()
	)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file('res://main.tscn')


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Quit.tscn")


func _on_rules_pressed() -> void:
	get_tree().change_scene_to_file('res://UI/instructions.tscn')
	
