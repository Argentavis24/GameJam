extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var health: int = 100

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash = get_node_or_null("slash")

var is_hurt: bool = false

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle horizontal movement & sprite/slash flipping
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

	# Play walking and idle animations when not hurt
	if sprite and not is_hurt:
		if velocity.x != 0:
			sprite.play("walk")
		else:
			sprite.play("idle")

	# Handle attack input
	if Input.is_action_just_pressed("attack"):
		attack()

func attack() -> void:
	if slash and slash.has_method("play_slash"):
		slash.play_slash()

func take_damage(amount: int) -> void:
	if health <= 0:
		return
		
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
		await sprite.animation_finished
	is_hurt = false

func die() -> void:
	is_hurt = true
	velocity = Vector2.ZERO
	
	# Disable physics loop so inputs or gravity won't override the death state
	set_physics_process(false)
	
	# Safely disable the collision shape
	var col = get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", true)

	if sprite:
		sprite.play("die")
		await sprite.animation_finished
	else:
		await get_tree().create_timer(1.0).timeout

	queue_free()
