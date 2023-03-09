extends Node2D

var in_radius = false
var host = null
@onready var network = get_node("/root/Main/Network")

var smelted_copper = 0 #How much smelted copper the inventory has
var smelted_iron = 0 #How much smelted copper the inventory has
var smelted_platinum = 0 #How much smelted copper the inventory has
var smelted_gold = 0 #How much smelted copper the inventory has
var smelted_baitium = 0 #How much smelted copper the inventory has
	
func _on_inventory_radius_body_exited(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("RESET")
		in_radius = false

func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E"):
		host = network.get_node(str(multiplayer.get_unique_id()))
		if(host.smelted_copper_amt >= 1 or host.smelted_iron_amt >= 1 or host.smelted_platinum_amt >= 1 or host.smelted_gold_amt >= 1 or host.smelted_baitium_amt >= 1): #Put smelted IN
			print("PUT SMELTED ORE IN")
			rpc("store_smelted_ore")

@rpc("any_peer", "call_local", "reliable", 1)
func store_smelted_ore():
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if host.smelted_copper_amt >= 1:
		host.smelted_copper_amt -= 1
		smelted_copper += 1
	elif host.smelted_iron_amt >= 1:
		host.smelted_iron_amt -= 1
		smelted_iron += 1
	elif host.smelted_platinum_amt >= 1:
		host.smelted_platinum_amt -= 1
		smelted_platinum += 1
	elif host.smelted_gold_amt >= 1:
		host.smelted_gold_amt -= 1
		smelted_gold += 1
	elif host.smelted_baitium_amt >= 1:
		host.smelted_baitium_amt -= 1
		smelted_baitium += 1
