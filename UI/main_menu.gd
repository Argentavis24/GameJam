extends Control

@onready var label: Label = $Name

var animation_done := false

func _ready() -> void:
	label.modulate.a = 0.0
	
	var tween = create_tween()
	#tween.set_parallel(true)
	tween.tween_interval(0)
	tween.tween_property(label,"modulate:a" , 1.0 , 3.0)


	









	
	
