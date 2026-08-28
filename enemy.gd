extends CharacterBody2D

@export var health: int = 30

func take_damage(amount: int) -> void:
	health -= amount
	print("Monster health remaining: ", health)
	if health <= 0:
		queue_free()
