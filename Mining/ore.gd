extends Node2D

var type = 0
var in_radius = false
var host
var picked_up = false
var rotation_speed = 0.0
@onready var float_text = preload("res://UI/float_text.tscn")
@onready var objects = get_node("/root/Main/Objects")

func _ready():
	$OreSprite.frame = type

func _physics_process(_delta):
	rotate(rotation_speed)
	if in_radius:
		if Input.is_action_just_pressed("E") and not picked_up and Global.ore_in_radius == 1:
			host = get_node("/root/Main/Network").get_node(str(multiplayer.get_unique_id()))
			if host.total < host.max_capacity:
				var floaty_text = float_text.instantiate()
				floaty_text.global_position = global_position + Vector2(randi_range(-25, -30), randi_range(-16, -24))
				if type == 0:
					floaty_text.text = "+1 raw copper"
					host.copper += 1
				elif type == 1:
					floaty_text.text = "+1 raw iron"
					host.iron += 1
				elif type == 2:
					floaty_text.text = "+1 raw platinum"
					host.platinum += 1
				elif type == 3:
					floaty_text.text = "+1 raw gold"
					host.gold += 1
				elif type == 4:
					floaty_text.text = "+1 raw baitium"
					host.baitium += 1
				Global.ore_in_radius = 0
				host.play_pickup_sound()
				objects.add_child(floaty_text)
				rpc("grab_ore")

@rpc("any_peer", "call_local", "reliable")
func grab_ore():
	picked_up = true
	queue_free()
