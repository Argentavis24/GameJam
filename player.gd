extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var max_health: int = 100
@export var health: int = 100
@export var attack_cooldown: float = 0.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var slash: Area2D = null

var is_hurt: bool = false
var can_attack: bool = true

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
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		
		if sprite:
			sprite.flip_h = (direction < 0)
			
		if slash:
			slash.position.x = -abs(slash.position.x) if direction < 0 else abs(slash.position.x)
			slash.scale.x = -abs(slash.scale.x) if direction < 0 else abs(slash.scale.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if sprite and not is_hurt:
		if velocity.x != 0:
			sprite.play("walk")
		else:
			sprite.play("idle")

	if Input.is_action_just_pressed("attack") and can_attack and not is_hurt:
		attack()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://UI/ConfirmToQuit.tscn")

func attack() -> void:
	can_attack = false
	
	if slash and slash.has_method("play_slash"):
		slash.play_slash()
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
	
	
	

func take_damage(amount: int) -> void:
	if health <= 0:
		return
		
	health -= amount
	health = max(0, health)
	print("Player health: ", health)
	
	sync_hp_bar()
	
	if health <= 0:
		die()
	else:
		play_hurt_animation()

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

	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("die"):
		sprite.play("die")
		await sprite.animation_finished
	else:
		await get_tree().create_timer(1.0).timeout

	get_tree().change_scene_to_file("res://UI/GameOver.tscn")
