extends Node2D

var in_radius = false
var onCooldown = false

func _process(_delta):
	if(in_radius and not onCooldown):
		if(Input.is_action_just_pressed("E")):
			print("SLOW!!")
			var enemies = get_tree().get_nodes_in_group("enemy")
			for enemy in enemies:
				enemy.slowed(true)
			onCooldown = true
			$Cooldown.start()
			$SlowDuration.start()


func _on_cooldown_timeout():
	onCooldown = false


func _on_slow_duration_timeout():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.slowed(false)
