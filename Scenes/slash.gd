extends Area2D

@export var damage: int = 10
@export var active_duration: float = 0.2
@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var hit_targets: Array[Node] = []

func _ready() -> void:
	add_to_group("slash")
	visible = false
	monitoring = false
	z_index = 10

func play_slash() -> void:
	visible = true
	monitoring = true
	hit_targets.clear()

	if sprite:
		sprite.frame = 0
		sprite.play()

	if not is_inside_tree():
		return
	await get_tree().physics_frame

	if not is_inside_tree():
		return
	check_damage()

	if not is_inside_tree():
		return
	await get_tree().create_timer(active_duration).timeout

	if is_inside_tree():
		visible = false
		monitoring = false

func check_damage() -> void:
	# -------------------------
	# Physics bodies
	# -------------------------
	var bodies := get_overlapping_bodies()
	for body in bodies:
		if body == get_parent():
			continue
		if body.is_in_group("player"):
			continue
		if body in hit_targets:
			continue
		if body.has_method("take_damage"):
			hit_targets.append(body)
			body.take_damage(damage)
			print("Slash hit: ", body.name, " for ", damage, " damage")

	# -------------------------
	# Areas
	# -------------------------
	var areas := get_overlapping_areas()
	for area in areas:
		if area == self:
			continue
		if area.get_parent() == get_parent():
			continue
		if area in hit_targets:
			continue
		if area.has_method("take_damage"):
			hit_targets.append(area)
			area.take_damage(damage)
			print("Slash hit area: ", area.name, " for ", damage, " damage")
