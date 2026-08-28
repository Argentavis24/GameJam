extends Control

@onready var scroll_container: ScrollContainer = $TextureRect/ScrollContainer  # adjust to your actual path
@onready var label: Label = $Ins
const SCROLL_SPEED = 300.0
var animation_done := false

func _ready() -> void:
	label.modulate.a = 0.0
	var tween = create_tween()

	tween.tween_property(label,"modulate:a" , 1.0 , 0.01)
	tween.tween_callback(func(): animation_done = true)
	tween.tween_callback(func():
		start_attention_pulse()
	)

func start_attention_pulse() -> void:
	var start_pos = label.position
	var float_tween = create_tween()
	float_tween.set_loops()
	float_tween.tween_property(label, "position:y", start_pos.y - 8, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(label, "position:y", start_pos.y, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		scroll_container.scroll_vertical -= SCROLL_SPEED * delta
	elif Input.is_action_pressed("ui_down"):
		scroll_container.scroll_vertical += SCROLL_SPEED * delta
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file('res://UI/MainMenu.tscn')






	
