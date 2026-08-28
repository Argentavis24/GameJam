extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

@export var health: int = 100
@export var attack_cooldown: float = 0.6  # Adjust time in seconds between slashes

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash = get_node_or_null("slash")

var is_hurt: bool = false
var can_attack: bool = true

func _ready() -> void:
	add_to_group("player")

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

	# Check can_attack before processing attack input
	if Input.is_action_just_pressed("attack") and can_attack and not is_hurt:
		attack()

func attack() -> void:
	can_attack = false
	
	if slash and slash.has_method("play_slash"):
		await slash.play_slash() # Wait for slash animation to complete
	
	# Wait out cooldown duration
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

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
	set_physics_process(false)
	
	var col = get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", true)

	if sprite:
		sprite.play("die")
		await sprite.animation_finished
	else:
		await get_tree().create_timer(1.0).timeout
	
	queue_free()
	
	get_tree().change_scene_to_file('res://UI/GameOver.tscn')
