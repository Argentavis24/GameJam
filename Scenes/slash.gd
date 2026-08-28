extends Area2D

@export var damage: int = 10
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	hide()
	monitoring = false

func play_slash() -> void:
	show()
	monitoring = true
	
	if sprite:
		sprite.frame = 0 # Resets animation to the first frame
		sprite.play()
		await sprite.animation_finished # Waits until the full animation completes
	else:
		await get_tree().create_timer(0.2).timeout
		
	hide()
	monitoring = false

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _on_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target and target.has_method("take_damage"):
		target.take_damage(damage)
