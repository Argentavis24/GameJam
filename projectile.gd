extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
@export var lifetime: float = 5.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	if sprite:
		sprite.play("boss_range_attack")

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	await get_tree().create_timer(lifetime).timeout

	if is_inside_tree():
		queue_free()


func set_direction(new_direction: Vector2) -> void:
	if new_direction.length() > 0.0:
		direction = new_direction.normalized()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

			print(
				"Projectile hit player for ",
				damage,
				" damage"
			)

		queue_free()
