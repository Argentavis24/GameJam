extends Area2D

@export var damage: int = 10
@export var active_duration: float = 0.3

@onready var sprite = get_node_or_null("AnimatedSprite2D")

func _ready() -> void:
	visible = false
	monitoring = false
	z_index = 10

func play_slash() -> void:
	visible = true
	monitoring = true
	
	if sprite:
		sprite.frame = 0
		sprite.play()

	# Wait 1 physics frame to fetch overlapping hitboxes reliably
	await get_tree().physics_frame
	check_damage()

	await get_tree().create_timer(active_duration).timeout
	visible = false
	monitoring = false

func check_damage() -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body == get_parent() or body.is_in_group("player"):
			continue
			
		if body.has_method("take_damage"):
			body.take_damage(damage)

	var areas = get_overlapping_areas()
	for area in areas:
		var parent = area.get_parent()
		if parent and parent != get_parent() and not parent.is_in_group("player"):
			if parent.has_method("take_damage"):
				parent.take_damage(damage)

func _on_body_entered(body: Node2D) -> void:
	if body == get_parent() or body.is_in_group("player"):
		return
		
	if body.has_method("take_damage"):
		body.take_damage(damage)
