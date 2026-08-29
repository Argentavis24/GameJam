extends Area2D

signal hit_target

@export var speed := 250.0
var velocity_dir := Vector2.RIGHT
var damage := 5

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	rotation = velocity_dir.angle()

func _physics_process(delta: float) -> void:
	position += velocity_dir * speed * delta

func _on_body_entered(body: Node) -> void:
	print("Projectile touched: ", body.name, " | groups: ", body.get_groups())
	if body.is_in_group("player"):
		print("Player confirmed — dealing damage and emitting hit_target")
		if body.has_method("take_damage"):
			body.take_damage(damage)
		hit_target.emit()
		queue_free()
	elif body.is_in_group("boss") or body == get_parent():
		return
