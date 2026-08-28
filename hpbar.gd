extends CanvasLayer


@export var heart_scene : PackedScene

var max_hp = 10
var current_hp = 3

func _ready() -> void:
	setup_hp()


func setup_hp():
	validate_hp()
	clean_current_representation()
	draw_hearts()
	
func heal():
	current_hp += 1
	setup_hp()
	
func hit():
	current_hp -= 1
	setup_hp()
	
func validate_hp():
		current_hp = [current_hp, max_hp].min()
		if current_hp <=0:
			get_parent().die()

func clean_current_representation():
	for child in $HBoxContainer.get_children():
		child.queue_free()
		
func draw_hearts():
	for x in current_hp:
		var heart_instance = heart_scene.instantiate()
		$HBoxContainer.add_child(heart_instance)
	
