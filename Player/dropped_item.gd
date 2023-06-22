extends Node2D

var type = 0
var in_radius = false
var host = null

func _ready():
	$ItemSprite.frame = type

func _process(_delta):
	if in_radius and Input.is_action_just_pressed("interact"):
		rpc("grab_item")

@rpc("any_peer", "call_local", "reliable", 1)
func grab_item():
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if type == 0:
		host.crushed_amt += 1
	elif type == 1:
		host.geode_amt += 1
	elif type == 2:
		host.smelted_copper_amt += 1
	elif type == 3:
		host.smelted_iron_amt += 1
	elif type == 4:
		host.smelted_platinum_amt += 1
	elif type == 5:
		host.smelted_gold_amt += 1
	elif type == 6:
		host.smelted_baitium_amt += 1
	queue_free()
