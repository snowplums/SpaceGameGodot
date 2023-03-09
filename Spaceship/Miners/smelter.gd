extends Node2D

var in_radius = false
var host = null
@onready var network = get_node("/root/Main/Network")

var crushed_amt = 0 #Amount of crushed copper smelting (add other ores below)

var smelted_copper = 0 # Amount of smelted copper
var smelted_iron = 0
var smelted_platinum = 0
var smelted_gold = 0
var smelted_baitium = 0
var ores = [smelted_copper, smelted_iron, smelted_platinum, smelted_gold, smelted_baitium]
var max_smelted_ores = 1 #Max number of smelted ores the smelter can carry
	
func _on_smelter_radius_body_exited(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("RESET")
		in_radius = false

func start_smelting():
	if smelted_copper != max_smelted_ores:
		$SmelterTimer.start()


func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E") and network.get_node(str(multiplayer.get_unique_id())).crushed_amt >= 1: #Put geode IN
		print("PUT CRUSHED IN")
		rpc("smelt_ore")
	elif in_radius and Input.is_action_just_pressed("E") and ores.max() >= 1: #Take crushed geode OUT
		print("TOOK SMELTED OUT")
		rpc("grab_smelted_ore")
		#host.can_move = false (if want animation to play make it so player cant move)

@rpc("any_peer", "call_local", "reliable", 1)
func smelt_ore():
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if host.crushed_amt >= 1 and (crushed_amt+smelted_copper+smelted_iron+smelted_platinum+smelted_gold+smelted_baitium) < max_smelted_ores:
		$AnimatedSprite2D.play("start")
		host.crushed_amt -= 1
		crushed_amt += 1
		$SmelterTimer.start()

@rpc("any_peer", "call_local", "reliable", 1)
func grab_smelted_ore():
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if ores.max() >= 1:
		$AnimatedSprite2D.play("idle")
		var ore = ores.find(ores.max())
		if ore == 0:
			host.smelted_copper_amt += 1
		elif ore == 1:
			host.smelted_iron_amt += 1
		elif ore == 2:
			host.smelted_platinum_amt += 1
		elif ore == 3:
			host.smelted_gold_amt += 1
		elif ore ==4:
			host.smelted_baitium_amt += 1
		ores[ore] -= 1
		print("Crushed: " + str(ores[ore]))
		print("Geode: " + str(crushed_amt))


func _on_smelter_timer_timeout():
	# Have choose random ore later
	if crushed_amt >= 1:
		crushed_amt -= 1
		var random_ore = randi_range(0,4)
		ores[random_ore] += 1
		if (smelted_copper+smelted_iron+smelted_platinum+smelted_gold+smelted_baitium) <= max_smelted_ores: #In smelted_copper add all other ores as well
			start_smelting()
		print("Smelted: " + str(ores[random_ore]))
		print("Crushed (unsmelted): " + str(crushed_amt))
	
