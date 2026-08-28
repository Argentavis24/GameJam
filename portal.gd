extends Area2D

@export_file("*.tscn") var target_scene: String = "res://Scenes/NextLevel.tscn"

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

# Prefixed _body with underscore to eliminate the UNUSED_PARAMETER warning
func _on_body_entered(_body: Node2D) -> void:
	teleport()

func teleport() -> void:
	if target_scene != "" and ResourceLoader.exists(target_scene):
		get_tree().change_scene_to_file(target_scene)
	else:
		print("Error: Target scene path is invalid or missing in Portal Inspector!")
