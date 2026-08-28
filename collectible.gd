extends Area2D


func _on_body_entered(body:Node2D) -> void:
	body.collectible_pickup()
	queue_free()
