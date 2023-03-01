extends Node2D

var in_radius = false
var host = null
@onready var network = get_node("/root/Main/Network")

var geode = 0 #Amount of geodes smelting

var crushed_amt = 0 # Amount of crushed geode
#var crushed_iron = 0 (example for other ores)
var max_crushed_ores = 1 #Max number of crushed ores the crusher can carry

func _on_crusher_radius_body_entered(body):
	if body.is_in_group("player"):
		in_radius = true
	
func _on_crusher_radius_body_exited(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("RESET")
		in_radius = false

func start_crushing():
	if crushed_amt != max_crushed_ores:
		$CrusherTimer.start()


func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E") and network.get_node(str(multiplayer.get_unique_id())).geode_amt >= 1: #Put geode IN
		print("PUT GEODE IN")
		rpc("crush_geode")
	elif in_radius and Input.is_action_just_pressed("E") and crushed_amt >= 1: #Take crushed geode OUT
		print("TOOK CRUSHED OUT")
		rpc("grab_crushed_ore")
		#host.can_move = false (if want animation to play make it so player cant move)

@rpc("any_peer", "call_local", "reliable", 1)
func crush_geode():
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if host.geode_amt >= 1 and (geode+crushed_amt) < max_crushed_ores:
		host.geode_amt -= 1
		geode += 1
		$AnimatedSprite2D.play("start")
		$CrusherTimer.start()

@rpc("any_peer", "call_local", "reliable", 1)
func grab_crushed_ore():
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if crushed_amt >= 1:
		$AnimatedSprite2D.play("idle")
		host.crushed_amt += 1
		crushed_amt -= 1
	print("Crushed: " + str(crushed_amt))
	print("Geode: " + str(geode))


func _on_crusher_timer_timeout():
	# Have choose random ore later
	if geode >= 1:
		geode -= 1
		crushed_amt += 1
		if (crushed_amt) != max_crushed_ores: #In crushed_amt add all other ores as well
			start_crushing()
		print("Crushed: " + str(crushed_amt))
		print("Geode: " + str(geode))
	
