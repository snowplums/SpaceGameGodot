extends StaticBody2D

@onready var collision = $CollisionShape2D
@onready var area = $Area2D
@onready var network = get_node("/root/Main/Network")
var host

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_down"):
		area.set_deferred("monitoring", true)
	if event.is_action_released("move_down"):
		area.set_deferred("monitoring", false)

func _on_area_2d_body_entered(_body):
	collision.set_deferred("disabled", true)


func _on_area_2d_body_exited(_body):
	collision.set_deferred("disabled", false)
	area.set_deferred("monitoring", false)
