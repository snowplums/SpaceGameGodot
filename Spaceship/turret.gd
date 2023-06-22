extends Node2D

@export var bullet_speed = 1000
@export var fire_rate = 0.2
@export var bullet_damage = 4.0
@export var bullet_pierce = 1
@export var bullet_amount = 4
@export var blast_radius = 1
@export var spread = 20

@export var base_turret_rate = 0.2
@export var shotgun_turret_rate = 0.4
@export var sniper_turret_rate = 0.75
@export var explosive_turret_rate = 0.5

var in_use = false
var active = false
const bullet = preload("res://Bullet/Bullet.tscn")
var can_fire = true
var in_radius = false
var host = null
var aim_location

var mode = 1 # 1 is base turret (pistol), 2 is shotgun turret, 3 is sniper turret, 4 is explosive turret

var on = false

func _process(_delta):
	if mode == 1:
		fire_rate = base_turret_rate
	elif mode == 2:
		fire_rate = shotgun_turret_rate
	elif mode == 3:
		bullet_speed = 1200
		fire_rate = sniper_turret_rate
	elif mode == 4:
		fire_rate = explosive_turret_rate
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

	if(in_use and active and Input.is_action_just_pressed("E")):
		rpc("turret_deactivate")
		host.can_move = true
		host.on_turret = false
	if in_radius and active:
		rpc("turret_active", $Sprite2D.rotation)
	turret()
		

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
	if in_use == true and active == true and in_radius == true and mode == 1: #BASE TURRET
		get_node("Sprite2D").look_at(get_global_mouse_position())
#		if Input.is_action_just_pressed("E"):
#			rpc("turret_deactivate")
#			host.can_move = true
#			print("E")
		if Input.is_action_pressed("left_click") and can_fire:
			aim_location = get_global_mouse_position()
			rpc("send_mouse_pos", aim_location)
			rpc("turret_fire")
			can_fire = false
			await get_tree().create_timer(fire_rate).timeout
			can_fire = true
	elif in_use == true and active == true and in_radius == true and mode == 2: #SHOTGUN
		get_node("Sprite2D").look_at(get_global_mouse_position())
		if Input.is_action_pressed("left_click") and can_fire:
			aim_location = get_global_mouse_position()
			rpc("send_mouse_pos", aim_location)
			rpc("shotgun_fire")
			can_fire = false
			await get_tree().create_timer(fire_rate).timeout
			can_fire = true
	elif in_use == true and active == true and in_radius == true and mode == 3: #SNIPER
		get_node("Sprite2D").look_at(get_global_mouse_position())
		if Input.is_action_pressed("left_click") and can_fire:
			aim_location = get_global_mouse_position()
			rpc("send_mouse_pos", aim_location)
			rpc("sniper_fire")
			can_fire = false
			await get_tree().create_timer(fire_rate).timeout
			can_fire = true
	elif in_use == true and active == true and in_radius == true and mode == 4: #ROCKET
		get_node("Sprite2D").look_at(get_global_mouse_position())
		if Input.is_action_pressed("left_click") and can_fire:
			aim_location = get_global_mouse_position()
			rpc("send_mouse_pos", aim_location)
			rpc("explosive_fire")
			can_fire = false
			await get_tree().create_timer(fire_rate).timeout
			can_fire = true

@rpc("any_peer", "call_remote")
func send_mouse_pos(mouse_pos):
	aim_location = mouse_pos
	
@rpc("any_peer", "call_local")
func turret_fire():
	$ShootNoise.pitch_scale = randf_range(0.9, 1.1)
	$ShootNoise.play()
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation = get_node("Sprite2D").rotation
	bullet_instance.set_damage(bullet_damage)
	bullet_instance.direction = (aim_location - global_position).normalized()
	get_node("/root/Main/Objects").add_child(bullet_instance)

@rpc("any_peer", "call_local")
func shotgun_fire():
	$ShootNoise.pitch_scale = randf_range(0.9, 1.1)
	$ShootNoise.play()
	for i in bullet_amount:
		var bullet_instance = bullet.instantiate()
		bullet_instance.position = get_global_position()
		bullet_instance.rotation = get_node("Sprite2D").rotation
		bullet_instance.set_damage(bullet_damage / 2)
		bullet_instance.direction = (aim_location + Vector2(randf_range(-spread, spread), randf_range(-spread, spread)) - global_position).normalized()
		get_node("/root/Main/Objects").add_child(bullet_instance)

@rpc("any_peer", "call_local")
func sniper_fire():
	$ShootNoise.pitch_scale = randf_range(0.9, 1.1)
	$ShootNoise.play()
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation = get_node("Sprite2D").rotation
	bullet_instance.set_damage(bullet_damage * 2.5)
	bullet_instance.set_pierce(bullet_pierce + 2)
	bullet_instance.direction = (aim_location - global_position).normalized()
	get_node("/root/Main/Objects").add_child(bullet_instance)

@rpc("any_peer", "call_local")
func explosive_fire():
	$ShootNoise.pitch_scale = randf_range(0.9, 1.1)
	$ShootNoise.play()
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation = get_node("Sprite2D").rotation
	bullet_instance.set_damage(bullet_damage)
	bullet_instance.direction = (aim_location - global_position).normalized()
	get_node("/root/Main/Objects").add_child(bullet_instance)
