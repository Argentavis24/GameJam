extends CharacterBody2D

enum State { PASSIVE, WIELDING, CHASE, ATTACK, DEAD }

@export var health: int = 30
@export var speed: float = 100.0
@export var detection_range: float = 200.0
@export var attack_range: float = 40.0
@export var damage: int = 15

@export var attack_delay: float = 0.5  # Wind-up delay before attack hits
@export var attack_cooldown: float = 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_state: State = State.PASSIVE
var player: CharacterBody2D = null
var is_attacking: bool = false
var facing_left: bool = false

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			player = get_node_or_null("../player")

	var dist_to_player = global_position.distance_to(player.global_position) if player else 9999.0

	match current_state:
		State.PASSIVE:
			velocity.x = 0
			if sprite:
				sprite.play("passive_idle")
			
			if dist_to_player <= detection_range:
				trigger_wield()

		State.WIELDING:
			velocity.x = 0

		State.CHASE:
			if not is_attacking:
				update_facing_direction()
				
				if dist_to_player <= attack_range:
					velocity.x = 0
					start_attack_sequence()
				else:
					var dir = -1.0 if facing_left else 1.0
					velocity.x = dir * speed
					if sprite:
						sprite.play("hostile_run")

	move_and_slide()

func update_facing_direction() -> void:
	if not player:
		return
		
	# Determine if player is to the left of the monster
	facing_left = (player.global_position.x < global_position.x)
	
	if sprite:
		sprite.flip_h = facing_left

func trigger_wield() -> void:
	current_state = State.WIELDING
	update_facing_direction()
	
	if sprite:
		sprite.play("wield")
		await sprite.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
		
	current_state = State.CHASE

func start_attack_sequence() -> void:
	is_attacking = true
	current_state = State.ATTACK
	velocity.x = 0
	
	# Lock in facing direction at start of attack
	update_facing_direction()

	if sprite:
		sprite.frame = 0
		sprite.play("hostile attack")

	# Telegraph delay
	await get_tree().create_timer(attack_delay).timeout

	# Verify player is within range and on the side the attack landed
	if player:
		var current_dist = global_position.distance_to(player.global_position)
		var player_is_left = (player.global_position.x < global_position.x)
		
		# Only hit if player is within range AND on the side the attack was swung toward
		if current_dist <= attack_range + 15.0 and player_is_left == facing_left:
			if player.has_method("take_damage"):
				player.take_damage(damage)

	await get_tree().create_timer(attack_cooldown).timeout
	
	is_attacking = false
	current_state = State.CHASE

func take_damage(amount: int) -> void:
	health -= amount
	print("Monster health remaining: ", health)
	
	if current_state == State.PASSIVE:
		trigger_wield()

	if health <= 0:
		die()

func die() -> void:
	current_state = State.DEAD
	queue_free()
