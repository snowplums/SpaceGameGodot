extends Node2D

@export var bullet_speed = 1000
@export var fire_rate = 0.2
@export var in_use = false
@export var active = false

const bullet = preload("res://spaceship/bullet.tscn")
var can_fire = true
var in_radius = false
var host = null

func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E") and !in_use:
		active = !active
		in_use = !in_use
	if in_radius and active:
		rpc("turret_active", rotation)
		in_use = true
	else:
		if host != null:
			host.can_move = true
		in_use = false
		active = false


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		in_radius = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		in_radius = false

@rpc(any_peer, call_local)
func turret_active(turret_rotation):
	in_use = true
	global_rotation = turret_rotation
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	host.can_move = false
	host.on_turret_activate(self)
