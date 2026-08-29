extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK, HEAL }
var state := State.IDLE

# Health
@export var max_health := 100
var health := max_health

# Attacks
@export var melee_damage := 10
@export var ranged_damage := 5
@export var projectile_speed := 150.0
@export var attack_telegraph := 0.6

# Boss settings
@export var attack_cooldown := 3.0
@export var melee_range := 80.0
@export var aggro_range := 400.0
@export var chase_speed := 100.0
@export var heal_amount := 20

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player = null
var can_attack := true
var has_healed := false
var is_dead := false
var is_attacking := false

func _ready() -> void:
	add_to_group("boss")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# Global health check to interrupt states immediately
	if health <= max_health * 0.3 and not has_healed and state != State.HEAL:
		state = State.HEAL
		
	match state:
		State.IDLE:
			idle_state()
		State.CHASE:
			chase_state(delta)
		State.ATTACK:
			attack_state()
		State.HEAL:
			heal_state()

func find_player() -> void:
	player = get_tree().get_first_node_in_group("player")

func idle_state() -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("boss_idle"):
		sprite.play("boss_idle")
	
	velocity = Vector2.ZERO
	move_and_slide()
	
	if player == null:
		find_player()
		return
		
	var distance := global_position.distance_to(player.global_position)
	if distance <= aggro_range:
		state = State.CHASE

func chase_state(delta: float) -> void:
	if player == null:
		find_player()
		state = State.IDLE
		return
		
	var distance := global_position.distance_to(player.global_position)
	
	# Player wandered back out of aggro range — go back to idle
	if distance > aggro_range:
		state = State.IDLE
		return
		
	# Close enough to attack and ready to do so
	if distance <= melee_range and can_attack:
		state = State.ATTACK
		return
		
	# Move toward the player (Runs when tracking or if within range but attack is on cooldown)
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("boss_move"):
		# Only play move animation if an attack animation isn't currently running
		if not sprite.animation.ends_with("attack") or not sprite.is_playing():
			sprite.play("boss_move")
		
	var direction: Vector2 = (player.global_position - global_position).normalized()
	
	# Maintain a slight distance or pursue if out of dead-stop range
	if distance <= melee_range - 10.0:
		velocity = Vector2.ZERO
	else:
		velocity = direction * chase_speed
		
	if direction.x != 0:
		sprite.flip_h = direction.x < 0
		
	move_and_slide()

func attack_state() -> void:
	# Block state re-entry while managing the attack sequence
	if is_attacking:
		return
		
	if player == null:
		state = State.IDLE
		return
		
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO
	move_and_slide()
	
	# 50/50 melee or ranged choice
	var attack_choice := randi_range(0, 1)
	if attack_choice == 0:
		melee_attack()
	else:
		await ranged_attack()
		
	# Transition back to chase immediately after the animation/firing execution triggers
	is_attacking = false
	state = State.CHASE
	
	# Start cooldown timer independently without blocking state processing loops
	start_cooldown()

func start_cooldown() -> void:
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func melee_attack() -> void:
	if player == null:
		return
		
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("boss_attack"):
		sprite.play("boss_attack")
		
	var distance := global_position.distance_to(player.global_position)
	if distance <= melee_range:
		if player.has_method("take_damage"):
			player.take_damage(melee_damage)
		print("Boss used melee!")

func ranged_attack() -> void:
	if player == null:
		return
		
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("boss_attack"):
		sprite.play("boss_attack")
		
	# Telegraph delay sequence
	await get_tree().create_timer(attack_telegraph).timeout
	
	if player == null or is_dead:
		return
		
	var projectile_scene = load("res://projectile.tscn")
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		
		# Fallback if marker node doesn't exist
		if has_node("RangedSpawn"):
			projectile.global_position = $RangedSpawn.global_position
		else:
			projectile.global_position = global_position
			
		var aim_dir: Vector2 = (player.global_position - projectile.global_position).normalized()
		projectile.velocity_dir = aim_dir
		projectile.damage = ranged_damage
		projectile.speed = projectile_speed
		
		get_tree().current_scene.add_child(projectile)
		print("Boss used ranged attack!")

func take_damage(amount: int) -> void:
	if is_dead:
		return
		
	health -= amount
	print("Boss HP: ", health)
	
	if health <= 0:
		die()

func heal_state() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("boss_heal"):
		sprite.play("boss_heal")
	
	health += heal_amount
	if health > max_health:
		health = max_health
	has_healed = true
	print("Boss healed! HP: ", health)
	
	state = State.CHASE

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	
	var col = get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", true)
		
	print("Boss defeated!")
	
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("boss_defeat"):
		sprite.play("boss_defeat")
		await sprite.animation_finished
		
	queue_free()
