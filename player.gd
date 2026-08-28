extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var health: int = 100

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash = $slash

var is_hurt: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		
		if sprite:
			sprite.flip_h = (direction < 0)
			
		if slash:
			slash.position.x = -abs(slash.position.x) if direction < 0 else abs(slash.position.x)
			slash.scale.x = -abs(slash.scale.x) if direction < 0 else abs(slash.scale.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if sprite and not is_hurt:
		if velocity.x != 0:
			sprite.play("walk")
		else:
			sprite.play("idle")

	if Input.is_action_just_pressed("attack"):
		attack()

func attack() -> void:
	if slash and slash.has_method("play_slash"):
		slash.play_slash()

func take_damage(amount: int) -> void:
	health -= amount
	print("Player health: ", health)
	
	if health <= 0:
		die()
	else:
		play_hurt_animation()

func play_hurt_animation() -> void:
	is_hurt = true
	if sprite:
		sprite.play("hurt")
		# Wait for animation to finish, or max 0.4 seconds fallback
		await get_tree().create_timer(0.4).timeout
	is_hurt = false

func die() -> void:
	is_hurt = true
	if sprite:
		sprite.play("die")
		await get_tree().create_timer(0.5).timeout
	queue_free()
