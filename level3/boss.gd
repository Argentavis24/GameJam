extends CharacterBody2D

enum State {
	IDLE,
	ATTACK,
	HEAL
}

var state := State.IDLE

# Health
@export var max_health := 100
var health := max_health

# Attacks
@export var melee_damage := 10
@export var ranged_damage := 5

# Boss settings
@export var attack_cooldown := 1.5
@export var melee_range := 80.0
@export var heal_amount := 20

var player = null
var can_attack := true
var has_healed := false


func _physics_process(delta):
	match state:
		State.IDLE:
			idle_state()

		State.ATTACK:
			attack_state()

		State.HEAL:
			heal_state()


func find_player():
	player = get_tree().get_first_node_in_group("player")


func idle_state():
	if player == null:
		find_player()
		return

	# Heal at 30% HP
	if health <= max_health * 0.3 and not has_healed:
		state = State.HEAL
		return

	# Attack
	if can_attack:
		state = State.ATTACK


func attack_state():
	if player == null:
		state = State.IDLE
		return

	can_attack = false

	# 50/50 melee or ranged
	var attack_choice := randi_range(0, 1)

	if attack_choice == 0:
		melee_attack()
	else:
		ranged_attack()

	# Attack cooldown
	await get_tree().create_timer(attack_cooldown).timeout

	can_attack = true
	state = State.IDLE


func melee_attack():
	if player == null:
		return

	var distance := global_position.distance_to(player.global_position)

	if distance <= melee_range:
		player.take_damage(melee_damage)

	print("Boss used melee!")


func ranged_attack():
	if player == null:
		return

	var projectile_scene = preload("res://projectile.tscn")
	var projectile = projectile_scene.instantiate()

	projectile.global_position = $RangedSpawn.global_position

	var direction = sign(player.global_position.x - global_position.x)

	projectile.direction = direction
	projectile.damage = ranged_damage

	get_tree().current_scene.add_child(projectile)

	print("Boss used ranged attack!")


func take_damage(amount):
	health -= amount

	print("Boss HP: ", health)

	if health <= 0:
		die()
		return

	# Heal once when below 30%
	if health <= max_health * 0.3 and not has_healed:
		state = State.HEAL


func heal_state():
	health += heal_amount

	if health > max_health:
		health = max_health

	has_healed = true

	print("Boss healed! HP: ", health)

	state = State.IDLE


func die():
	print("Boss defeated!")
	queue_free()
