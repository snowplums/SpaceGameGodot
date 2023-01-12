extends AnimatedSprite2D


func _ready():
	$StaticBody2D/CollisionShape2D.disabled = true
	$DoorLightStop.visible = false
	frame = 0
	
func _on_animation_finished():
	if animation == "door_close":
		frame = 19
		$StaticBody2D/CollisionShape2D.disabled = false
		$DoorLightStop.visible = true
		stop()
	if animation == "door_open":
		frame = 0
		$StaticBody2D/CollisionShape2D.disabled = true
		$DoorLightStop.visible = false
		stop()
