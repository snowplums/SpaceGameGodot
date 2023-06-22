extends Sprite2D

var in_radius = false
@onready var wavespawner = get_node("/root/Main/Wavespawner")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(_delta):
	if(in_radius):
		if(Input.is_action_just_pressed("E")):
			$Interact.play()
			$"Ship Directory UI".visible=!$"Ship Directory UI".visible
	else:
		$"Ship Directory UI".visible=false


func _on_directory_radius_body_exited(body):
	if body.is_in_group("player"):
		in_radius = false
		$AnimationPlayer.play("RESET")


func _on_x_pressed():
	$"Ship Directory UI".visible=false

@rpc("any_peer", "call_local", "reliable")
func planet_travel(planet_num):
	Global.current_planet = planet_num
	wavespawner.travel_to_planet()

func _on_go_button_pressed():
	if $"Ship Directory UI"/TextureButton/Picked.visible == true and Global.planets_unlocked == 1:
		rpc("planet_travel", 1)
	elif $"Ship Directory UI"/TextureButton2/Picked.visible == true and Global.planets_unlocked == 2:
		rpc("planet_travel", 2)
	elif $"Ship Directory UI"/TextureButton3/Picked.visible == true and Global.planets_unlocked == 5:
		rpc("planet_travel", 5)
	elif $"Ship Directory UI"/TextureButton4/Picked.visible == true and Global.planets_unlocked == 4:
		rpc("planet_travel", 4)
	elif $"Ship Directory UI"/TextureButton5/Picked.visible == true and Global.planets_unlocked == 3:
		rpc("planet_travel", 3)
