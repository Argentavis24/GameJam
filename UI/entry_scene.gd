extends Control

@onready var label: Label = $Name
@onready var label1: Label = $Start

func _ready() -> void:
	label.modulate.a = 0.0
	label1.modulate.a = 0.0
	var tween = create_tween()
	#tween.set_parallel(true)
	tween.tween_property(label,"modulate:a" , 1.0, 2.0)
	tween.tween_interval(0.25)
	tween.tween_property(label1,"modulate:a" , 1.0, 3.0)
	


	
	
