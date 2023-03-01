extends Node2D

@export var bullet_speed = 1000
@export var fire_rate = 0.2
@export var bullet_damage = 10

var in_use = false
var active = false
const bullet = preload("res://Bullet/Bullet.tscn")
var can_fire = true
var in_radius = false
var host = null

var on = false

func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E"):
		if(!in_use):
			active = true
			host = get_node("/root/Main/Network").get_node(str(multiplayer.get_unique_id()))
			host.on_turret = true
			host.velocity = Vector2.ZERO
			host.can_move = false
		else:
			rpc("turret_deactivate")
			host.can_move = true
			host.on_turret = false
			print("E")

	if(in_use and active and Input.is_action_just_pressed("E")):
		rpc("turret_deactivate")
		host.can_move = true
		host.on_turret = false
		print("E")
	if in_radius and active:
		rpc("turret_active", $Sprite2D.rotation)
	turret()
		


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		in_radius = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		in_radius = false

@rpc("any_peer", "call_local")
func turret_active(turret_rotation):
	in_use = true
	$Sprite2D.global_rotation = turret_rotation
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))

@rpc("any_peer", "call_local", "reliable")
func turret_deactivate():
	in_use = false
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	active = false

func turret():
	if in_use == true and active == true:
		get_node("Sprite2D").look_at(get_global_mouse_position())
#		if Input.is_action_just_pressed("E"):
#			rpc("turret_deactivate")
#			host.can_move = true
#			print("E")
		if Input.is_action_pressed("left_click") and can_fire:
			rpc("turret_fire")
			can_fire = false
			await get_tree().create_timer(fire_rate).timeout
			can_fire = true

@rpc("any_peer", "call_local")
func turret_fire():
	$ShootNoise.pitch_scale = randf_range(0.9, 1.1)
	$ShootNoise.play()
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation = get_node("Sprite2D").rotation
	bullet_instance.set_damage(bullet_damage)
	bullet_instance.direction = (get_global_mouse_position() - global_position).normalized()
	get_node("/root/Main/Objects").add_child(bullet_instance)
