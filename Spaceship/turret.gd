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
		rpc("turret_active", $Sprite2D.rotation)
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
	$Sprite2D.global_rotation = turret_rotation
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	host.can_move = false
	host.on_turret_activate(self)

func turret():
	if in_use == true:
		get_node("Sprite2D").look_at(get_global_mouse_position())
		if Input.is_action_pressed("ui_accept"):
			in_use = false
			active = false
		if Input.is_action_pressed("left_click") and can_fire:
			rpc("turret_fire")
			can_fire = false
			await get_tree().create_timer(fire_rate).timeout
			can_fire = true

func on_turret_activate(turret_node):
	in_use = true
	turret_scene = turret_node

@rpc(any_peer, call_local)
func turret_fire():
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = turret_scene.get_global_position()
	bullet_instance.rotation = turret_scene.rotation
	bullet_instance.apply_impulse(Vector2(bullet_speed, 0).rotated(turret_scene.get_node("Sprite2D").rotation), Vector2())
	get_node("/root/Main/Network").add_child(bullet_instance)
