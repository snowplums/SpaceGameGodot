extends Sprite2D

var in_radius = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(_delta):
	if(in_radius):
		if(Input.is_action_just_pressed("E")):
			$"Ship Directory UI".visible=!$"Ship Directory UI".visible
	else:
		$"Ship Directory UI".visible=false


func _on_directory_radius_body_entered(body):
	if body.is_in_group("player"):
		in_radius = true


func _on_directory_radius_body_exited(body):
	if body.is_in_group("player"):
		in_radius = false
		$AnimationPlayer.play("RESET")


func _on_x_pressed():
	$"Ship Directory UI".visible=false


func _on_go_button_pressed():
	if $"Ship Directory UI"/TextureButton/Picked.visible == true:
		print("earth")
	elif $"Ship Directory UI"/TextureButton2/Picked.visible == true:
		print("mars")
	elif $"Ship Directory UI"/TextureButton3/Picked.visible == true:
		print("ice")
	elif $"Ship Directory UI"/TextureButton4/Picked.visible == true:
		print("gas giant")
	elif $"Ship Directory UI"/TextureButton5/Picked.visible == true:
		print("moon")
