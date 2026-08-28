extends Area2D

@export_file("*.tscn") var target_scene: String = "res://UI/StoryLvl2-3.tscn"
@export var skull_manager_path: NodePath

func _ready() -> void:
	visible = false
	monitoring = false

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	var skull_manager = get_node_or_null(skull_manager_path)
	if skull_manager and skull_manager.has_signal("all_skulls_crushed"):
		skull_manager.all_skulls_crushed.connect(activate_portal)
	else:
		print("ERROR: skull_manager_path didn't resolve, or missing signal")

func activate_portal() -> void:
	print("ACTIVATING PORTAL")
	visible = true
	monitoring = true
func change_scene_1():
	get_tree().change_scene_to_file('res://UI/StoryLvl2-3.tscn')
func _on_body_entered(_body: Node2D) -> void:
	call_deferred("change_scene_1")
	
