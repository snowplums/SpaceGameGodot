extends StaticBody2D

@onready var collision = $CollisionShape2D
@onready var area = $Area2D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_down"):
		area.set_deferred("monitoring", true)
	if event.is_action_released("move_down"):
		await get_tree().create_timer(0.2).timeout
		area.set_deferred("monitoring", false)

func _on_area_2d_body_entered(_body):
	collision.set_deferred("disabled", true)


func _on_area_2d_body_exited(_body):
	collision.set_deferred("disabled", false)
	area.set_deferred("monitoring", false)
