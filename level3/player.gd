extends CharacterBody2D

# =========================
# PLAYER SETTINGS
# =========================

@export var speed := 200.0
@export var jump_force := -400.0
@export var gravity := 1000.0

@export var max_health := 100
@export var melee_damage := 10

var health := max_health
var can_attack := true


# =========================
# PLAYER MOVEMENT
# =========================

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Left and right movement
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * speed

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# Melee attack
	if Input.is_action_just_pressed("attack"):
		attack()

	# Apply movement
	move_and_slide()


# =========================
# MELEE ATTACK
# =========================

func attack():
	if not can_attack:
		return

	can_attack = false

	# Check everything inside the attack hitbox
	for body in $AttackHitbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(melee_damage)

	# Attack cooldown
	await get_tree().create_timer(0.5).timeout
	can_attack = true


# =========================
# TAKE DAMAGE
# =========================

func take_damage(amount):
	health -= amount

	print("Player HP: ", health)

	if health <= 0:
		die()


# =========================
# PLAYER DEATH
# =========================

func die():
	print("Player died!")
	queue_free()
