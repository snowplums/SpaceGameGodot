extends Sprite2D


func _ready():
	frame = 0
	$StaticBody2D/CollisionShape2D.disabled = true

func door_open():
	$AnimationPlayer.play("door_open")
	
func door_close():
	$AnimationPlayer.play("door_close")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "door_close":
		$StaticBody2D/CollisionShape2D.disabled = false
	elif anim_name == "door_open":
		$StaticBody2D/CollisionShape2D.disabled = true
