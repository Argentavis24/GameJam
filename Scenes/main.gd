extends Node2D



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('ui_cancel'):
		get_tree().change_scene_to_file('res://UI/GameOver.tscn')
