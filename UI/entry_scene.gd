extends Control

@onready var label: Label = $Name
@onready var label1: Label = $Start

var animation_done := false

func _ready() -> void:
	label.modulate.a = 0.0
	label1.modulate.a = 0.0
	var tween = create_tween()
	#tween.set_parallel(true)
	tween.tween_interval(1)
	tween.tween_property(label,"modulate:a" , 0.5, 3.0)
	tween.tween_interval(0.25)
	tween.tween_property(label1,"modulate:a" ,0.5, 1.0)
	tween.tween_callback(func(): animation_done = true)
	
	
func _process(delta: float) -> void:
	if animation_done and Input.is_action_just_pressed("StartGame"):
		get_tree().change_scene_to_file('res://main.tscn')



	
	
