extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_crushed: bool = false

func _ready() -> void:
	add_to_group("destructibles")
	
	if sprite:
		sprite.play("skull idle")

# Called only when slash.gd explicitly hits the skull
func take_damage(_amount: int = 0) -> void:
	crush()

func crush() -> void:
	if is_crushed:
		return
		
	is_crushed = true
	
	if collision:
		collision.set_deferred("disabled", true)
		
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("skull crush"):
		sprite.play("skull crush")
		await sprite.animation_finished
	else:
		await get_tree().create_timer(0.2).timeout
		
	queue_free()
