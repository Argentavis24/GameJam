extends Node2D

@export var enemy_scene: PackedScene
@export var delay_between_turns: float = 1.0

@onready var spawn_points: Array[Node] = get_children()

func _ready() -> void:
	# Small delay to allow the level scene tree to fully load
	await get_tree().process_frame
	start_spawning_turns()

func start_spawning_turns() -> void:
	if spawn_points.is_empty():
		print("Warning: No spawn points found under SpawnerManager!")
		return

	for i in range(spawn_points.size()):
		var current_point = spawn_points[i] as Node2D
		print("Spawning enemy ", i + 1, " at position: ", current_point.global_position)
		
		var enemy = spawn_enemy_at(current_point.global_position)
		
		if is_instance_valid(enemy):
			await enemy.tree_exited
			
		await get_tree().create_timer(delay_between_turns).timeout

	print("All 4 turns completed!")

func spawn_enemy_at(spawn_position: Vector2) -> Node2D:
	if not enemy_scene:
		print("Error: No Enemy Scene assigned in SpawnerManager Inspector!")
		return null

	var enemy_instance = enemy_scene.instantiate() as Node2D
	
	# Place enemy directly in the level root scene
	get_tree().current_scene.add_child(enemy_instance)
	enemy_instance.global_position = spawn_position
	
	# Ensure the enemy appears in front of background visuals
	enemy_instance.z_index = 5
	
	return enemy_instance
