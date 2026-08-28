extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Node = null
const LOW_HEALTH_THRESHOLD: int = 40

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return

	if player.health < LOW_HEALTH_THRESHOLD:
		if sprite.animation != "weak":
			sprite.play("weak lantern")
	else:
		if sprite.animation != "idle":
			sprite.play("lantern idle")
