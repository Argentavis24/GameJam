extends Area2D

@export var speed := 250.0
var velocity_dir := Vector2.RIGHT
var damage := 5
var has_hit := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	rotation = velocity_dir.angle()

	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("boss_range_attack"):
		sprite.play("boss_range_attack")

func _physics_process(delta: float) -> void:
	if has_hit:
		return
	position += velocity_dir * speed * delta

func _on_body_entered(body: Node) -> void:
	if has_hit:
		return

	if body.is_in_group("player"):
		has_hit = true

		if body.has_method("take_damage"):
			body.take_damage(damage)

		if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("boss_attack_hit"):
			sprite.play("boss_attack_hit")
			await sprite.animation_finished
		queue_free()
	elif body.is_in_group("boss") or body == get_parent():
		return
