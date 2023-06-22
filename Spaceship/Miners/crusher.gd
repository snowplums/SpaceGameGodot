extends Node2D

var in_radius = false
var host = null
@onready var network = get_node("/root/Main/Network")
@onready var float_text = preload("res://UI/float_text.tscn")
@onready var objects = get_node("/root/Main/Objects")

#var total_ores = 0
#var max_ores = 3
#var current_ore = 0
#var copper = 0
#var iron = 0
#var platinum = 0
#var gold = 0
#var baitium = 0

var ore_list: Array = []
	
func _on_crusher_radius_body_exited(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("RESET")
		in_radius = false

func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E"):
		host = network.get_node(str(multiplayer.get_unique_id()))
		if(host.copper >= 1 or host.iron >= 1 or host.platinum >= 1 or host.gold >= 1 or host.baitium >= 1): # If player has ore to input
			$AcceptSound.play()
			rpc("interact_crusher")
		else:
			$DenySound.play()
	if ore_list.size() >= 1 and $AnimatedSprite2D.animation == "idle":
		rpc("play_animation")
	if $AnimatedSprite2D.animation == "start":
		if $AnimatedSprite2D.frame == 15 and not $AudioStreamPlayer2D.playing and not $AudioStreamPlayer2D2.playing:
			$AudioStreamPlayer2D.play()
			$AudioStreamPlayer2D2.play()
	
@rpc("any_peer", "call_local", "reliable", 1)
func interact_crusher(): # Adds copper first, then iron, plat, gold, bait
	host = network.get_node(str(multiplayer.get_remote_sender_id()))
	if host.copper >= 1:
		host.copper -= 1
		if multiplayer.get_unique_id() == 1:
			ore_list.push_back(0)
	elif host.iron >= 1:
		host.iron -= 1
		if multiplayer.get_unique_id() == 1:
			ore_list.push_back(1)
	elif host.platinum >= 1:
		host.platinum -= 1
		if multiplayer.get_unique_id() == 1:
			ore_list.push_back(2)
	elif host.gold >= 1:
		host.gold -= 1
		if multiplayer.get_unique_id() == 1:
			ore_list.push_back(3)
	elif host.baitium >= 1:
		host.baitium -= 1
		if multiplayer.get_unique_id() == 1:
			ore_list.push_back(4)
	
func store_ore():
	if ore_list[0] == 0: # Check TYPE of first ore in list, then STORE it, then REMOVE it from list
		rpc("add_ore", 0)
	elif ore_list[0] == 1:
		rpc("add_ore", 1)
	elif ore_list[0] == 2:
		rpc("add_ore", 2)
	elif ore_list[0] == 3:
		rpc("add_ore", 3)
	elif ore_list[0] == 4:
		rpc("add_ore", 4)
	ore_list.remove_at(0)

@rpc("authority", "call_local", "reliable")
func add_ore(type):
	var floaty_text = float_text.instantiate()
	if type == 0:
		floaty_text.text = "+1 copper"
	elif type == 1:
		floaty_text.text = "+1 iron"
	elif type == 2:
		floaty_text.text = "+1 platinum"
	elif type == 3:
		floaty_text.text = "+1 gold"
	elif type == 4:
		floaty_text.text = "+1 baitium"
	floaty_text.global_position = global_position + Vector2(randi_range(-25, -30), randi_range(-16, -24))
	objects.add_child(floaty_text)
	Global.ores[type] += 1

@rpc("any_peer", "call_local", "reliable")
func play_animation():
	$AnimatedSprite2D.play("start")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "start" and multiplayer.get_unique_id() == 1:
		store_ore()
	$AnimatedSprite2D.play("idle")

#func _process(_delta):
#	print($CrusherTimer.time_left)
#	if in_radius and Input.is_action_just_pressed("E"):
#		host = network.get_node(str(multiplayer.get_unique_id()))
#		if(host.copper >= 1 or host.iron >= 1 or host.platinum >= 1 or host.gold >= 1 or host.baitium >= 1): #Put smelted IN
#			rpc("interact_crusher")
#		#host.can_move = false (if want animation to play make it so player cant move)
#
#@rpc("any_peer", "call_local", "reliable", 1)
#func interact_crusher():
#	if multiplayer.get_remote_sender_id() == 1:
#		rpc("crush_ore")
#
#
#@rpc("any_peer", "call_local", "reliable", 1)
#func crush_ore():
#	host = network.get_node(str(multiplayer.get_remote_sender_id()))
#	total_ores += 1
#	if host.copper >= 1:
#		current_ore = 0
#		host.copper -= 1
#		copper += 1
#	elif host.iron >= 1:
#		current_ore = 1
#		host.iron -= 1
#		iron += 1
#	elif host.platinum >= 1:
#		host.platinum -= 1
#		current_ore = 2
#		platinum += 1
#	elif host.gold >= 1:
#		current_ore = 3
#		host.gold -= 1
#		gold += 1
#	elif host.baitium >= 1:
#		current_ore = 4
#		host.baitium -= 1
#		baitium += 1
#	$AnimatedSprite2D.play("start")
#	$CrusherTimer.start()
#
#@rpc("any_peer", "call_local", "reliable", 1)
#func store_ore():
#	total_ores -= 1
#
#	if current_ore == 0:
#		copper -= 1
#		Global.ores[0] += 1
#	elif current_ore == 1:
#		iron -= 1
#		Global.ores[1] += 1
#	elif current_ore == 2:
#		platinum -= 1
#		Global.ores[2] += 1
#	elif current_ore == 3:
#		gold -= 1
#		Global.ores[3] += 1
#	elif current_ore == 4:
#		baitium -= 1
#		Global.ores[4] += 1
#
#	if total_ores >= 1: #In crushed_amt add all other ores as well
#		$AnimatedSprite2D.play("start")
#		$CrusherTimer.start()
#
	


