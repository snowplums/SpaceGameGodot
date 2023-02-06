extends Node2D

var in_radius = false
var host = null
@onready var network = get_node("/root/Main/Network")

var crushed_copper = 0 #Amount of crushed copper smelting (add other ores below)

var smelted_copper = 0 # Amount of smelted copper
#var crushed_iron = 0 (example for other ores)
var max_smelted_ores = 1 #Max number of smelted ores the smelter can carry

func _on_smelter_radius_body_entered(body):
	if body.is_in_group("player"):
		in_radius = true
	
func _on_smelter_radius_body_exited(body):
	if body.is_in_group("player"):
		in_radius = false

func start_smelting():
	if smelted_copper != max_smelted_ores:
		$SmelterTimer.start()


func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E") and network.get_node(str(multiplayer.get_unique_id())).crushed_copper_amt >= 1: #Put geode IN
		print("PUT CRUSHED IN")
		rpc("smelt_ore")
	elif in_radius and Input.is_action_just_pressed("E") and smelted_copper >= 1: #Take crushed geode OUT
		print("TOOK SMELTED OUT")
		rpc("grab_smelted_ore")
		#host.can_move = false (if want animation to play make it so player cant move)

@rpc(any_peer, call_local, reliable, 1)
func smelt_ore():
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if host.crushed_copper_amt >= 1 and (crushed_copper+smelted_copper) < max_smelted_ores:
		$AnimatedSprite2D.play("start")
		host.crushed_copper_amt -= 1
		crushed_copper += 1
		$SmelterTimer.start()

@rpc(any_peer, call_local, reliable, 1)
func grab_smelted_ore():
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if smelted_copper >= 1:
		$AnimatedSprite2D.play("idle")
		host.smelted_copper_amt += 1
		smelted_copper -= 1
	print("Crushed: " + str(smelted_copper))
	print("Geode: " + str(crushed_copper))


func _on_smelter_timer_timeout():
	# Have choose random ore later
	if crushed_copper >= 1:
		crushed_copper -= 1
		smelted_copper += 1
		if (smelted_copper) != max_smelted_ores: #In smelted_copper add all other ores as well
			start_smelting()
		print("Smelted: " + str(smelted_copper))
		print("Crushed (unsmelted): " + str(crushed_copper))
	
