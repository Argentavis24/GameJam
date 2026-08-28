extends Area2D





func _on_area_entered(area: Area2D) -> void:
	get_tree().change_scene_to_file('res://UI/StoryLvl2-3.tscn')
