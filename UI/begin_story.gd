extends Control

@onready var heading: Label = $TextureRect/Heading
@onready var content: Label = $Content  # confirm this path matches your actual tree
@onready var continue_label: Label = $Ins

var can_continue := false

func _ready() -> void:
	heading.modulate.a = 0.0
	content.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(heading, "modulate:a", 1.0, 1.0)
	tween.tween_interval(0.3)
	tween.tween_property(content, "modulate:a", 1.0, 2.0)
	tween.tween_callback(func():
		can_continue = true
		start_continue_float()
	)

func start_continue_float() -> void:
	var start_pos = continue_label.position
	var float_tween = create_tween()
	float_tween.set_loops()
	float_tween.tween_property(continue_label, "position:y", start_pos.y - 8, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(continue_label, "position:y", start_pos.y, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(_delta: float) -> void:
	if can_continue and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file('res://UI/Scene1BeginStry.tscn')  # set your actual next scene path
