extends CharacterBody2D

const SPEED = 300.0
const ACCELERATION = 2000.0
const JUMP_VELOCITY = -600.0

@export var max_health: int = 100
@export var health: int = 100
@export var attack_cooldown: float = 0.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sfx: AudioStreamPlayer2D = $jump_sfx
@onready var walk_sfx: AudioStreamPlayer2D = $walk_sfx
@onready var heal_sfx: AudioStreamPlayer2D = $heal_sfx
@onready var slash_sfx: AudioStreamPlayer2D = $slash_sfx
@onready var lose_sfx: AudioStreamPlayer2D = $lose_sfx
@onready var hurt_sfx: AudioStreamPlayer2D = $hurt_sfx

var slash: Area2D = null

var is_hurt: bool = false
var can_attack: bool = true
var is_slashing: bool = false
var was_f_pressed: bool = false


func _ready() -> void:
	add_to_group("player")

	slash = find_child("slash", true, false) as Area2D

	if not slash:
		slash = find_child("Slash", true, false) as Area2D

	await get_tree().process_frame
	sync_hp_bar()


func sync_hp_bar() -> void:
	var hp_bar = get_tree().get_first_node_in_group("hpbar")

	if hp_bar and hp_bar.has_method("update_health"):
		hp_bar.update_health(health, max_health)


func _physics_process(delta: float) -> void:

	# Don't move while attacking.
	if is_slashing:
		velocity.x = 0.0
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()

	# Left / right movement
	var direction := 0.0

	if Input.is_key_pressed(KEY_RIGHT):
		direction += 1.0

	if Input.is_key_pressed(KEY_LEFT):
		direction -= 1.0

	if direction != 0:

		velocity.x = move_toward(
			velocity.x,
			direction * SPEED,
			ACCELERATION * delta
		)

		if sprite:
			sprite.flip_h = direction < 0

		if slash:
			slash.position.x = (
				-abs(slash.position.x)
				if direction < 0
				else abs(slash.position.x)
			)

			slash.scale.x = (
				-abs(slash.scale.x)
				if direction < 0
				else abs(slash.scale.x)
			)

	else:

		velocity.x = move_toward(
			velocity.x,
			0,
			ACCELERATION * delta
		)

	move_and_slide()

	# Animations
	if sprite and not is_hurt:

		if not is_on_floor():

			sprite.speed_scale = 1.0
			sprite.play("jump")

		elif velocity.x != 0:

			sprite.speed_scale = clamp(
				abs(velocity.x) / SPEED,
				0.1,
				1.0
			)

			sprite.play("walk")

		else:

			sprite.speed_scale = 1.0
			sprite.play("idle")

	# F key detection
	var f_pressed_now := Input.is_physical_key_pressed(KEY_F)

	var f_just_pressed := (
		f_pressed_now and not was_f_pressed
	)

	was_f_pressed = f_pressed_now

	# Attack input
	var attack_pressed := (
		Input.is_action_just_pressed("attack")
		or (
			InputMap.has_action("slash")
			and Input.is_action_just_pressed("slash")
		)
		or f_just_pressed
	)

	if attack_pressed and can_attack and not is_hurt:
		attack()


func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file(
			"res://UI/ConfirmToQuit.tscn"
		)


func attack() -> void:

	can_attack = false
	is_slashing = true

	velocity.x = 0.0

	if slash and slash.has_method("play_slash"):
		slash.play_slash()

	slash_sfx.play()

	await get_tree().create_timer(
		attack_cooldown
	).timeout

	is_slashing = false
	can_attack = true


func take_damage(amount: int) -> void:

	if health <= 0:
		return

	health -= amount
	health = max(0, health)

	print("Player health: ", health)

	sync_hp_bar()

	if health <= 0:

		lose_sfx.play()
		die()

	else:

		play_hurt_animation()
		hurt_sfx.play()


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

	if (
		sprite
		and sprite.sprite_frames
		and sprite.sprite_frames.has_animation("die")
	):

		sprite.play("die")
		await sprite.animation_finished

	else:

		await get_tree().create_timer(1.0).timeout

	get_tree().change_scene_to_file(
		"res://UI/GameOver.tscn"
	)
