extends Area2D

@export var damage: int = 10
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	hide()
	monitoring = false

func play_slash() -> void:
	show()
	monitoring = false
	monitoring = true
	
	if sprite:
		sprite.frame = 0
		sprite.play()
		
	check_targets()

	if sprite:
		await sprite.animation_finished
	else:
		await get_tree().create_timer(0.2).timeout
		
	hide()
	monitoring = false

func check_targets() -> void:
	for body in get_overlapping_bodies():
		deal_damage(body)
	for area in get_overlapping_areas():
		deal_damage(area)

func deal_damage(target: Node) -> void:
	if target == null:
		return
		
	# Ignore the player and the slash itself
	if target.is_in_group("player") or target.name == "player" or target == get_parent():
		return

	# Check the target node directly
	if target.has_method("take_damage"):
		target.take_damage(damage)
		return

	# Check parent if a child Area2D was hit (e.g., child Area2D on Monster)
	var parent = target.get_parent()
	if parent and parent != get_parent() and parent.name != "player":
		if parent.has_method("take_damage"):
			parent.take_damage(damage)

func _on_body_entered(body: Node2D) -> void:
	deal_damage(body)

func _on_area_entered(area: Area2D) -> void:
	deal_damage(area)
