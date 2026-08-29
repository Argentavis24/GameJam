extends CharacterBody2D

enum State {
	PASSIVE,
	CHASE,
	ATTACK,
	DEAD
}

@export var health: int = 100
@export var speed: float = 80.0
@export var detection_range: float = 600.0
@export var attack_range: float = 450.0
@export var attack_cooldown: float = 2.0
@export var projectile_scene: PackedScene
@export var projectile_spawn_distance: float = 45.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_state: State = State.PASSIVE
var player: CharacterBody2D = null
var is_attacking: bool = false
var facing_left: bool = false

signal died


func _ready() -> void:
	add_to_group("boss")
	add_to_group("enemy")

	if sprite:
		sprite.play("boss_idle")


func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if not player:
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	var dist_to_player: float = 9999.0

	if player:
		dist_to_player = global_position.distance_to(player.global_position)

	match current_state:
		State.PASSIVE:
			velocity.x = 0.0

			if sprite and not is_attacking:
				sprite.play("boss_idle")

			if player and dist_to_player <= detection_range:
				current_state = State.CHASE

		State.CHASE:
			if not player:
				current_state = State.PASSIVE
				return

			update_facing_direction()

			if dist_to_player <= attack_range:
				velocity.x = 0.0
				start_attack_sequence()
			else:
				var direction: float = signf(
					player.global_position.x - global_position.x
				)

				velocity.x = direction * speed

				if sprite and not is_attacking:
					sprite.play("boss_move")

		State.ATTACK:
			velocity.x = 0.0

		State.DEAD:
			velocity = Vector2.ZERO

	move_and_slide()


func update_facing_direction() -> void:
	if not player:
		return

	facing_left = player.global_position.x < global_position.x

	if sprite:
		sprite.flip_h = facing_left


func start_attack_sequence() -> void:
	if is_attacking:
		return

	is_attacking = true
	current_state = State.ATTACK
	velocity.x = 0.0

	update_facing_direction()

	if sprite:
		sprite.frame = 0
		sprite.play("boss_attack")

		await get_tree().create_timer(0.3).timeout

		if current_state == State.DEAD:
			return

		fire_projectile()

		await sprite.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout

		if current_state == State.DEAD:
			return

		fire_projectile()

	if current_state == State.DEAD:
		return

	await get_tree().create_timer(attack_cooldown).timeout

	if current_state != State.DEAD:
		is_attacking = false
		current_state = State.CHASE


func fire_projectile() -> void:
	if not projectile_scene:
		print("ERROR: Projectile Scene is not assigned!")
		return

	if not player:
		return

	var projectile: Node = projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	var direction: Vector2 = global_position.direction_to(
		player.global_position
	)

	if direction == Vector2.ZERO:
		if facing_left:
			direction = Vector2.LEFT
		else:
			direction = Vector2.RIGHT

	projectile.global_position = (
		global_position
		+ direction * projectile_spawn_distance
	)

	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)


func take_damage(amount: int) -> void:
	if current_state == State.DEAD:
		return

	health -= amount
	health = max(health, 0)

	print("Boss health remaining: ", health)

	if health <= 0:
		die()
	else:
		if current_state == State.PASSIVE:
			current_state = State.CHASE


func die() -> void:
	if current_state == State.DEAD:
		return

	current_state = State.DEAD
	is_attacking = false
	velocity = Vector2.ZERO

	var collision: Node = get_node_or_null("CollisionShape2D")

	if collision:
		collision.set_deferred("disabled", true)

	if (
		sprite
		and sprite.sprite_frames
		and sprite.sprite_frames.has_animation("boss_defeat")
	):
		sprite.frame = 0
		sprite.play("boss_defeat")
		await sprite.animation_finished

	emit_signal("died")
	queue_free()
