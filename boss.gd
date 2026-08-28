extends CharacterBody2D

enum State {
	IDLE,
	ATTACK,
	HEAL
}

var state = State.IDLE

var health = 100
var max_health = 100

var melee_damage = 10
var has_healed = false
var can_attack = true

var player = null

var projectile = preload("res://projectile.tscn")


func _ready():
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta):
	match state:
		State.IDLE:
			idle_state()

		State.ATTACK:
			attack_state()

		State.HEAL:
			heal_state()


func idle_state():
	if player != null and can_attack:
		state = State.ATTACK


func attack_state():
	if not can_attack:
		state = State.IDLE
		return

	can_attack = false

	# Randomly choose melee or ranged attack
	var attack = randi_range(0, 1)

	if attack == 0:
		melee_attack()
	else:
		ranged_attack()

	await get_tree().create_timer(1.5).timeout

	can_attack = true

	# Heal if boss is low on health
	if health <= max_health * 0.3 and not has_healed:
		state = State.HEAL
	else:
		state = State.IDLE


func melee_attack():
	if player != null:
		var distance = global_position.distance_to(player.global_position)

		if distance < 80:
			player.take_damage(melee_damage)


func ranged_attack():
	if player == null:
		return

	var new_projectile = projectile.instantiate()

	new_projectile.global_position = $RangedSpawn.global_position

	get_tree().current_scene.add_child(new_projectile)

	# Tell projectile which direction to travel
	new_projectile.direction = sign(
		player.global_position.x - global_position.x
	)


func take_damage(amount):
	health -= amount

	print("Boss HP: ", health)

	if health <= 0:
		die()
		return

	# Heal when below 30% health
	if health <= max_health * 0.3 and not has_healed:
		state = State.HEAL


func heal_state():
	health += 20

	if health > max_health:
		health = max_health

	has_healed = true

	print("Boss healed! HP: ", health)

	state = State.IDLE


func die():
	print("Boss defeated!")
	queue_free()
