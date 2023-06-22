extends Node2D

var in_radius = false
var onCooldown = false
var prevSpread

@onready var turrets = get_node("/root/Main/World/Spaceship/Turrets").get_children()

func _process(_delta):
	if(in_radius and not onCooldown):
		if(Input.is_action_just_pressed("E")):
			print("orchard")
			rpc("grab_fruit", true)
			onCooldown = true
			$Cooldown.start()
			$FruitDuration.start()


func _on_cooldown_timeout():
	onCooldown = false
	
@rpc("any_peer", "call_local", "reliable", 1)
func grab_fruit(fruitOn):
	var host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if fruitOn:
		host.MAX_SPEED += 20
		host.CARRY_MULTIPLIER -= 20
		for turret in turrets:
			prevSpread = turret.spread
			if turret.spread > 10:
				turret.spread -= 10
			else:
				turret.spread = 1
	else:
		host.MAX_SPEED -= 20
		host.CARRY_SPEED -= 20
		for turret in turrets:
			print("Changed to previous spread of: ", prevSpread)
			turret.spread = prevSpread


func _on_fruit_duration_timeout():
	rpc("grab_fruit", false)
