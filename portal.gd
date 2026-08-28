extends Area2D

@export_file("*.tscn") var target_scene: String = "res://UI/StoryLvl2.tscn"
@export var spawner_path: NodePath

func _ready() -> void:
	print("Portal _ready() running")
	visible = false
	monitoring = false

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	print("spawner_path value: ", spawner_path)
	var spawner = get_node_or_null(spawner_path)
	print("spawner resolved to: ", spawner)

	if spawner:
		print("spawner has signal 'all_enemies_defeated': ", spawner.has_signal("all_enemies_defeated"))
		if spawner.has_signal("all_enemies_defeated"):
			spawner.all_enemies_defeated.connect(activate_portal)
			print("Successfully connected to spawner signal")
	else:
		print("spawner_path did NOT resolve to a valid node")

func activate_portal() -> void:
	print("ACTIVATING PORTAL")
	visible = true
	monitoring = true

func _on_body_entered(_body: Node2D) -> void:
	get_tree().change_scene_to_file(target_scene)
