extends Control

@onready var label: Label = $Name

func _ready() -> void:
	label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(label,"modulate:a" , 1.0, 5.0)

	
	
