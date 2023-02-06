extends Node
@onready var turret = get_node("/root/Main/World/Spaceship/Turrets/Turret")
@onready var inv = get_node("/root/Main/World/Spaceship/Miners/Inventory")
var in_radius = false

var upgrade_price = 1
var upgrade_amount = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(in_radius):
		if(Input.is_action_just_pressed("E")):
			$CanvasLayer.visible=!$CanvasLayer.visible
	else:
		$CanvasLayer.visible=false

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		in_radius=true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		in_radius=false

func _on_button_pressed():
	if(inv.smelted_copper >= upgrade_price):
		rpc("upgrade_turret", upgrade_amount)
		print("upgraded")



@rpc(any_peer, call_local, reliable)
func upgrade_turret(_upgrade_val):
	inv.smelted_copper -= upgrade_price
	turret.bullet_damage+= upgrade_amount
	upgrade_price +=upgrade_amount
	
