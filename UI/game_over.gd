extends Control

@onready var arrow: Label = $Arrow
@onready var retry_button: Button = $Menu/Retry
@onready var main_menu_button: Button = $Menu/Menu

var buttons: Array[Button] = []
var arrow_base_pos: Vector2
var hover_tween: Tween

func _ready() -> void:
	arrow.pivot_offset = arrow.size / 2

	buttons = [retry_button, main_menu_button]

	for i in buttons.size():
		buttons[i].focus_entered.connect(_on_button_focused.bind(buttons[i]))
		buttons[i].focus_neighbor_top = buttons[(i - 1 + buttons.size()) % buttons.size()].get_path()
		buttons[i].focus_neighbor_bottom = buttons[(i + 1) % buttons.size()].get_path()

	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	call_deferred("_initial_focus")

func _initial_focus() -> void:
	retry_button.grab_focus()

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

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file('res://main.tscn')  # adjust to your actual gameplay scene path

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file('res://UI/MainMenu.tscn')  
