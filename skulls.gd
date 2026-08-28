extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_crushed: bool = false

func _ready() -> void:
	# Start in idle animation
	if sprite:
		sprite.play("skull idle")

# Called when the player's slash area hits this skull
func take_damage(amount: int = 0) -> void:
	crush()

func crush() -> void:
	if is_crushed:
		return
		
	is_crushed = true
	
	# Disable collision so it cannot be hit multiple times
	if collision:
		collision.set_deferred("disabled", true)
		
	if sprite:
		sprite.play("skull crush")
		await sprite.animation_finished
		
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# If hit by the player's slash area directly
	if area.name.to_lower().contains("slash") or area.get_parent().is_in_group("player"):
		crush()
