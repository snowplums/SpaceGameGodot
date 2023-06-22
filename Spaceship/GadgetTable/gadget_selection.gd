extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var card1 = $CanvasLayer/BackCard1
@onready var card2 = $CanvasLayer/BackCard2
@onready var card3 = $CanvasLayer/BackCard3
@onready var card1_label = $CanvasLayer/BackCard1/Label
@onready var card2_label = $CanvasLayer/BackCard2/Label
@onready var card3_label = $CanvasLayer/BackCard3/Label
@onready var card1_desc = $CanvasLayer/BackCard1/Label/Label2
@onready var card2_desc = $CanvasLayer/BackCard2/Label/Label2
@onready var card3_desc = $CanvasLayer/BackCard3/Label/Label2

@onready var orchard = preload("res://Gadgets/orchard_tree.tscn")
@onready var repellent = preload("res://Gadgets/repellent_button.tscn")
@onready var emp = preload("res://Gadgets/slow_down_button.tscn")
# Shield is global.hasShield
# Lockdown is global.hasLockdown

var orchard_desc : String = "A tree
that grows fruit which increase accuracy, speed, and carry speed."
var repellent_desc : String = "A repellent device that slows the enemy's next wave."
var emp_desc : String = "A device that hacks the surrounding enemies, making them move slower."
var shield_desc : String = "A small extra health shield which will regenerate when broken."
var lockdown_desc : String = "Greatly reduces the damage taken during a ship lockdown."

var gadget_list = ["Orchard", "Repellent", "EMP", "Shield", "Lockdown"]
var descs = [orchard_desc, repellent_desc, emp_desc, shield_desc, lockdown_desc]

var gadget1_index : int
var gadget2_index : int
var gadget3_index : int

var votes_1 : int = 0
var votes_2 : int = 0
var votes_3 : int = 0
var my_vote : int = 0

var cards_anim_fin : bool = false
var gadget_gotten : bool = false

func rand_num(from,to):
	var arr = []
	for i in range(from,to):
		arr.append(i)
	arr.shuffle()
	return arr

@rpc("authority", "call_local", "reliable")
func send_values(sent1, sent2, sent3):
	gadget1_index = sent1
	gadget2_index = sent2
	gadget3_index = sent3
	
func _ready():
	anim_player.play("slide_up")
	if multiplayer.get_unique_id() == 1:
		var gadget_arr = rand_num(0, gadget_list.size()-1)
		rpc("send_values", gadget_arr[0], gadget_arr[1], gadget_arr[2])
	await get_tree().create_timer(1).timeout
	card1_label.text = gadget_list[gadget1_index]
	card2_label.text = gadget_list[gadget2_index]
	card3_label.text = gadget_list[gadget3_index]
	card1_desc.text = descs[gadget1_index]
	card2_desc.text = descs[gadget2_index]
	card3_desc.text = descs[gadget3_index]

func _process(_delta):
	print(votes_1, votes_2, votes_3)
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "slide_up" and gadget_gotten == false:
		anim_player.play("flip_card")
	elif anim_name == "flip_card":
		anim_player.play("flip_card_2")
	elif anim_name == "flip_card_2":
		anim_player.play("flip_card_3")
	elif anim_name == "flip_card_3":
		cards_anim_fin = true
	if anim_name == "slide_up" and gadget_gotten == true:
		queue_free()

@rpc("any_peer", "call_local", "reliable")
func vote_gadget_1():
	votes_1 += 1

@rpc("any_peer", "call_local", "reliable")
func vote_gadget_2():
	votes_2 += 1

@rpc("any_peer", "call_local", "reliable")
func vote_gadget_3():
	votes_3 += 1

@rpc("any_peer", "call_local", "reliable")
func unvote_gadget_1():
	votes_1 -= 1

@rpc("any_peer", "call_local", "reliable")
func unvote_gadget_2():
	votes_2 -= 1

@rpc("any_peer", "call_local", "reliable")
func unvote_gadget_3():
	votes_3 -= 1

func finish_voting():
	if votes_1 > votes_2 and votes_1 > votes_3:
		get_gadget(gadget_list[0])
	elif votes_2 > votes_1 and votes_2 > votes_3:
		get_gadget(gadget_list[1])
	elif votes_3 > votes_1 and votes_3 > votes_2:
		get_gadget(gadget_list[2])

func get_gadget(gadget_name):
	gadget_gotten = true
	anim_player.play_backwards("slide_up")
	if gadget_name == gadget_list[0]: #Orchard
		var orchard_scene = orchard.instantiate()
		get_node("/root/Main/World/Spaceship/Gadgets/Orchard").add_child(orchard_scene)
	elif gadget_name == gadget_list[1]: #Repellent
		var repellent_scene = repellent.instantiate()
		get_node("/root/Main/World/Spaceship/Gadgets/Repellent").add_child(repellent_scene)
	elif gadget_name == gadget_list[2]: #EMP
		var emp_scene = emp.instantiate()
		get_node("/root/Main/World/Spaceship/Gadgets/SlowDown").add_child(emp_scene)
	elif gadget_name == gadget_list[3]: #Shield
		Global.hasShield = true
	elif gadget_name == gadget_list[4]: #Lockdown
		Global.hasLockdown = true

func _on_button_1_pressed():
	if my_vote != 1:
		card1.material.set("shader_parameter/color", Color(0, 0, 0, 255))
		var tween = get_tree().create_tween()
		tween.tween_property(card1, "scale", Vector2(7,7), 0.05)
		
		# Reset other cards
		card2.material.set("shader_parameter/color", Color(0, 0, 0, 0))
		var tween1 = get_tree().create_tween()
		tween1.tween_property(card2, "scale", Vector2(6,6), 0.05)
		
		card3.material.set("shader_parameter/color", Color(0, 0, 0, 0))
		var tween2 = get_tree().create_tween()
		tween2.tween_property(card3, "scale", Vector2(6,6), 0.05)
		
		rpc("vote_gadget_1")
	if my_vote == 2:
		rpc("unvote_gadget_2")
	elif my_vote == 3:
		rpc("unvote_gadget_3")
	my_vote = 1


func _on_button_2_pressed():
	if my_vote != 2:
		card2.material.set("shader_parameter/color", Color(0, 0, 0, 255))
		var tween = get_tree().create_tween()
		tween.tween_property(card2, "scale", Vector2(7,7), 0.05)
		
		# Reset other cards
		card1.material.set("shader_parameter/color", Color(0, 0, 0, 0))
		var tween1 = get_tree().create_tween()
		tween1.tween_property(card1, "scale", Vector2(6,6), 0.05)
		
		card3.material.set("shader_parameter/color", Color(0, 0, 0, 0))
		var tween2 = get_tree().create_tween()
		tween2.tween_property(card3, "scale", Vector2(6,6), 0.05)
		
		rpc("vote_gadget_2")
	if my_vote == 1:
		rpc("unvote_gadget_1")
	elif my_vote == 3:
		rpc("unvote_gadget_3")
	my_vote = 2

func _on_button_3_pressed():
	if my_vote != 3:
		card3.material.set("shader_parameter/color", Color(0, 0, 0, 255))
		var tween = get_tree().create_tween()
		tween.tween_property(card3, "scale", Vector2(7,7), 0.05)
		
		# Reset other cards
		card1.material.set("shader_parameter/color", Color(0, 0, 0, 0))
		var tween1 = get_tree().create_tween()
		tween1.tween_property(card1, "scale", Vector2(6,6), 0.05)
		
		card2.material.set("shader_parameter/color", Color(0, 0, 0, 0))
		var tween2 = get_tree().create_tween()
		tween2.tween_property(card2, "scale", Vector2(6,6), 0.05)
		
		rpc("vote_gadget_3")
	if my_vote == 1:
		rpc("unvote_gadget_1")
	elif my_vote == 2:
		rpc("unvote_gadget_2")
	my_vote = 3

func _on_button_1_mouse_entered():
	if my_vote == 0 and cards_anim_fin:
		var tween = get_tree().create_tween()
		tween.tween_property(card1, "scale", Vector2(7,7), 0.2)


func _on_button_1_mouse_exited():
	if my_vote == 0 and cards_anim_fin:
		var tween = get_tree().create_tween()
		tween.tween_property(card1, "scale", Vector2(6,6), 0.2)


func _on_button_2_mouse_entered():
	if my_vote == 0 and cards_anim_fin:
		var tween = get_tree().create_tween()
		tween.tween_property(card2, "scale", Vector2(7,7), 0.2)


func _on_button_2_mouse_exited():
	if my_vote == 0 and cards_anim_fin:
		var tween = get_tree().create_tween()
		tween.tween_property(card2, "scale", Vector2(6,6), 0.2)


func _on_button_3_mouse_entered():
	if my_vote == 0 and cards_anim_fin:
		var tween = get_tree().create_tween()
		tween.tween_property(card3, "scale", Vector2(7,7), 0.2)


func _on_button_3_mouse_exited():
	if my_vote == 0 and cards_anim_fin:
		var tween = get_tree().create_tween()
		tween.tween_property(card3, "scale", Vector2(6,6), 0.2)
