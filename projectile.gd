extends Area2D

var speed = 300
var direction = 1
var damage = 5


func _physics_process(delta):
	position.x += speed * direction * delta


func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
