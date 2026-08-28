extends Area2D

@export var damage: int = 10
@export var active_duration: float = 0.2

@onready var sprite = get_node_or_null("AnimatedSprite2D")

func _ready() -> void:
	add_to_group("slash")
	visible = false
	monitoring = false
	z_index = 10

func play_slash() -> void:
	visible = true
	monitoring = true
	
	if sprite:
		sprite.frame = 0
		sprite.play()

	await get_tree().physics_frame
	check_damage()

	await get_tree().create_timer(active_duration).timeout
	visible = false
	monitoring = false

func check_damage() -> void:
	# Check physics bodies (Enemies)
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body == get_parent() or body.is_in_group("player"):
			continue
		if body.has_method("take_damage"):
			body.take_damage(damage)

	# Check areas (Skulls / Destructibles)
	var areas = get_overlapping_areas()
	for area in areas:
		if area == self or area.get_parent() == get_parent():
			continue
		if area.has_method("take_damage"):
			area.take_damage(damage)
