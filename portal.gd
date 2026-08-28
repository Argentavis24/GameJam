extends Area2D

@export_file("*.tscn") var target_scene: String = "res://Scenes/NextLevel.tscn"

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func change_scene():
	get_tree().change_scene_to_file('res://UI/StoryLvl2.tscn')
func _on_body_entered(_body: Node2D) -> void:
	call_deferred("change_scene")
