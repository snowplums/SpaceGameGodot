extends Node2D

var in_radius = false
var host = null
@onready var network = get_node("/root/Main/Network")
	
func _on_inventory_radius_body_exited(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("RESET")
		in_radius = false

func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E"):
		host = network.get_node(str(multiplayer.get_unique_id()))
		if(host.copper >= 1 or host.iron >= 1 or host.platinum >= 1 or host.gold >= 1 or host.baitium >= 1): #Put smelted IN
			print("PUT SMELTED ORE IN")
			rpc("store_smelted_ore")

@rpc("any_peer", "call_local", "reliable", 1)
func store_smelted_ore():
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if host.copper >= 1:
		host.copper -= 1
		Global.ores[0] += 1
	elif host.iron >= 1:
		host.iron -= 1
		Global.ores[1] += 1
	elif host.platinum >= 1:
		host.platinum -= 1
		Global.ores[2] += 1
	elif host.gold >= 1:
		host.gold -= 1
		Global.ores[3] += 1
	elif host.baitium >= 1:
		host.baitium -= 1
		Global.ores[4] += 1
