extends CanvasLayer

@export var heart_scene : PackedScene

var max_hearts: int = 10


func _ready() -> void:
	add_to_group("hpbar")

func update_health(current_player_hp: int, max_player_hp: int) -> void:
	clean_current_representation()
	
	if heart_scene == null:
		print("ERROR: heart_scene is not assigned in the Inspector!")
		return

	var container = get_node_or_null("HBoxContainer")
	if container == null:
		print("ERROR: HBoxContainer child missing under HPBar!")
		return

	# Calculate remaining hearts proportional to max health
	var hp_ratio: float = float(current_player_hp) / float(max_player_hp)
	var active_hearts: int = ceil(hp_ratio * max_hearts)

	for x in range(active_hearts):
		var heart_instance = heart_scene.instantiate()
		container.add_child(heart_instance)

func clean_current_representation() -> void:
	var container = get_node_or_null("HBoxContainer")
	if container:
		for child in container.get_children():
			child.queue_free()
