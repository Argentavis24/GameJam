extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var slash = $slash

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Handle attack
	if Input.is_action_just_pressed("attack"):
		attack()

func attack() -> void:
	if slash and slash.has_method("play_slash"):
		slash.play_slash()



func _quit_game():
		get_tree().change_scene_to_file("res://UI/Quit.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('ui_cancel'):
		call_deferred("_quit_game")
		
