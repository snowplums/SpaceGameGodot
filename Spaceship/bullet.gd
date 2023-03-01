extends RigidBody2D
	
func set_damage(new_damage):
	$HitBox.damage = new_damage

func shot_from_turret(new_value):
	$HitBox.shotFromTurret = new_value


func _on_body_entered(body):
	if !body.is_in_group("player"):
		queue_free()
