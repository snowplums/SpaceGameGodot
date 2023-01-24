extends AnimatedSprite2D


func _ready():
	$StaticBody2D/CollisionShape2D.disabled = true
	frame = 0
	
func _on_animation_finished():
	if animation == "door_close":
		frame = 19
		$StaticBody2D/CollisionShape2D.disabled = false
		stop()
	if animation == "door_open":
		frame = 0
		$StaticBody2D/CollisionShape2D.disabled = true
		stop()

func door_open():
	playing = true
	play("door_open",true)
	
func door_close():
	playing = true
	play("door_close")
