extends CharacterBody2D

var speed = 200.0
var jump_force = -400.0
var gravity = 1000.0

var health = 100
var melee_damage = 10

var can_attack = true


func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movement
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * speed

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# Attack
	if Input.is_action_just_pressed("attack"):
		attack()

	move_and_slide()


func attack():
	if not can_attack:
		return

	can_attack = false

	for body in $AttackHitbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(melee_damage)

	await get_tree().create_timer(0.5).timeout

	can_attack = true


func take_damage(amount):
	health -= amount

	if health <= 0:
		die()


func die():
	queue_free()
