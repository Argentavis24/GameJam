extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
enum State { PASSIVE, HOSTILE, ATTACK }

@export var move_speed: float = 60.0
@export var attack_cooldown: float = 1.0
@export var attack_damage: int = 10
@export var wield_time: float = 0.3   # time for weapon "wield" anim before becoming hostile

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = Timer.new()

var state: State = State.PASSIVE
var player: Node2D = null
var player_in_attack_range: bool = false
var can_attack: bool = true
var is_transitioning: bool = false  # locks state during wield/holster/attack anims

func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	attack_area.body_entered.connect(_on_attack_body_entered)
	attack_area.body_exited.connect(_on_attack_body_exited)

	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.timeout.connect(func(): can_attack = true)

	sprite.animation_finished.connect(_on_animation_finished)

	_play("passive_idle")

func _physics_process(_delta: float) -> void:
	if is_transitioning:
		return

	match state:
		State.PASSIVE:
			velocity = Vector2.ZERO
			_play("passive_idle")

		State.HOSTILE:
			if player == null:
				state = State.PASSIVE
				return

			if player_in_attack_range and can_attack:
				_start_attack()
				return

			if player_in_attack_range:
				# in range but on cooldown, just stand and face player
				velocity = Vector2.ZERO
				_play("hostile_idle")
			else:
				var dir: Vector2 = (player.global_position - global_position).normalized()
				velocity = dir * move_speed
				_play("hostile_run")
				_face_direction(dir)

		State.ATTACK:
			velocity = Vector2.ZERO # freeze during attack

	move_and_slide()

# ---------------- Detection (chase range) ----------------

func _on_detection_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player = body
	if state == State.PASSIVE:
		_wield_weapon()

func _on_detection_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		if state != State.ATTACK:
			_holster_weapon()

# ---------------- Melee range ----------------

func _on_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_attack_range = true

func _on_attack_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_attack_range = false

# ---------------- State transitions ----------------

func _wield_weapon() -> void:
	is_transitioning = true
	_play("weapon_wield")
	await get_tree().create_timer(wield_time).timeout
	state = State.HOSTILE
	is_transitioning = false

func _holster_weapon() -> void:
	is_transitioning = true
	_play("weapon_holster")
	await get_tree().create_timer(wield_time).timeout
	state = State.PASSIVE
	is_transitioning = false

func _start_attack() -> void:
	state = State.ATTACK
	is_transitioning = true
	can_attack = false
	_play("hostile_attack")
	attack_timer.start()
	# deal damage partway through the swing rather than instantly:
	await get_tree().create_timer(0.15).timeout
	_try_deal_damage()

func _try_deal_damage() -> void:
	if player_in_attack_range and player and player.has_method("take_damage"):
		player.take_damage(attack_damage)

func _on_animation_finished() -> void:
	if sprite.animation == "hostile_attack":
		is_transitioning = false
		state = State.HOSTILE if player else State.PASSIVE

# ---------------- Helpers ----------------

func _play(anim_name: String) -> void:
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func _face_direction(dir: Vector2) -> void:
	if dir.x != 0:
		sprite.flip_h = dir.x < 0
