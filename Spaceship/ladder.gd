extends Node2D

var bottom_in_radius = false
var top_in_radius = false
var host

func _process(_delta):
	if bottom_in_radius == true:
		if(Input.is_action_just_pressed("E")):
			$AudioStreamPlayer.play()
			#Tp to top of ladder
			host = get_node("/root/Main/Network").get_node(str(multiplayer.get_unique_id()))
			host.position.y -= 80
			host.top_down_mvmt = true
	elif top_in_radius == true:
		if(Input.is_action_just_pressed("E")):
			$AudioStreamPlayer.play()
			#Tp to bottom of ladder
			host = get_node("/root/Main/Network").get_node(str(multiplayer.get_unique_id()))
			host.position.y += 80
			host.top_down_mvmt = false
