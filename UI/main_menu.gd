extends Control

@onready var label: Label = $Name
@onready var label1: Label = $Play
@onready var label2: Label = $Exit
@onready var label3: Label = $Rules

var animation_done := false

func _ready() -> void:
	label.modulate.a = 0.0
	label1.modulate.a = 0.0
	label2.modulate.a = 0.0
	label3.modulate.a = 0.0
	
	
	var tween = create_tween()
	#tween.set_parallel(true)
	tween.tween_interval(1)
	tween.tween_property(label,"modulate:a" , 1.0 , 3.0)
	tween.tween_interval(0.25)
	tween.tween_property(label1,"modulate:a" ,1.0 , 1.0)
	tween.tween_property(label3,"modulate:a" ,1.0 , 1.0)
	tween.tween_property(label2,"modulate:a" ,1.0 , 1.0)
	tween.tween_callback(func(): animation_done = true)
	tween.tween_callback(func():
		start_attention_pulse()
	)


func start_attention_pulse() -> void:
	var start_pos = label1.position
	var float_tween = create_tween()
	float_tween.set_loops()
	float_tween.tween_property(label1, "position:y", start_pos.y - 8, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(label1, "position:y", start_pos.y, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	

'''
func _process(delta: float) -> void:
	if animation_done and Input.is_action_just_pressed("StartGame"):
		get_tree().change_scene_to_file('res://main.tscn')
		
'''




	
	
