extends RigidBody2D


func _on_body_entered(body):
	if !body.is_in_group("player"):
		queue_free()

func set_damage(new_damage):
	$Hitbox.damage = new_damage
