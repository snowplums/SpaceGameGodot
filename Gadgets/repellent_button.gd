extends Node2D

@onready var wavespawner = get_node("/root/Main/Wavespawner")

var in_radius = false
var onCooldown = false
var repellent_time = 10.0 # Seconds added to wave timer

func _process(_delta):
	if(in_radius and not onCooldown):
		if(Input.is_action_just_pressed("E")):
			var time_to_add = wavespawner.wavetimer.time_left + repellent_time
			wavespawner.wavetimer.stop()
			wavespawner.wavetimer.wait_time = time_to_add
			wavespawner.wavetimer.start()
			onCooldown = true
			$Cooldown.start()


func _on_cooldown_timeout():
	onCooldown = false
