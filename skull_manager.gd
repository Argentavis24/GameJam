extends Node

signal all_skulls_crushed

var total_skulls: int = 0
var crushed_count: int = 0

func _ready() -> void:
	await get_tree().process_frame
	var skulls = get_tree().get_nodes_in_group("destructibles")
	total_skulls = skulls.size()
	print("Tracking ", total_skulls, " skulls")

	for skull in skulls:
		if skull.has_signal("crushed"):
			skull.crushed.connect(_on_skull_crushed)

func _on_skull_crushed() -> void:
	crushed_count += 1
	print("Skulls crushed: ", crushed_count, "/", total_skulls)

	if crushed_count >= total_skulls:
		print("ALL SKULLS CRUSHED")
		all_skulls_crushed.emit()
