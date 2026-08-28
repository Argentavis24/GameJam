extends CharacterBody2D

var speed = 200.0
var jump_force = -400.0
var gravity = 1000.0

var health = 100
var melee_damage = 10

var can_attack = true

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("move_left", "move_right")

	velocity.x = direction * speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()
