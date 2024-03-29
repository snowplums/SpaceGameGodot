extends Node2D

var max_shield_health = 100
var ship_health = 1000 # Change in ui as well!
var shield_health = max_shield_health
var shield_regen_rate = 6.0
var reduction = 1.0

var fire_scene = preload("res://Spaceship/fire.tscn")
var firespawnpoint
var rng = RandomNumberGenerator.new()
var ship_fire_status = "not"
var ship_dark_status = false
var ship_hack_status = false
var random_room
var firerooms = ["no","no","no","no","no","no","no","no"]
var label_array = []
@onready var doors = get_tree().get_nodes_in_group("Door")

func take_damage(hitbox):
	if multiplayer.get_unique_id() == 1 and hitbox.shotFromTurret == false:
		rpc("update_damage", hitbox.damage)
	if hitbox.shotFromTurret == false:
		hitbox.get_parent().bullet_hit()

func take_damage_direct(damage):
	if multiplayer.get_unique_id() == 1:
		rpc("update_damage", damage)

@rpc("authority", "call_local")
func update_damage(damage):
	$Gadgets/ShieldTimer.start()
	if Global.hasShield and shield_health > 0:
		var new_shield_health = shield_health - (damage * reduction)
		shield_health = new_shield_health
		if shield_health < 0:
			shield_health = 0
	else:
		var new_ship_health = ship_health - (damage * reduction)
		ship_health = new_ship_health
		if ship_health < 0:
			ship_health = 0

func _ready():
	background()

func _process(delta):
	if $Gadgets/ShieldTimer.time_left <= 0:
		if shield_health < max_shield_health:
			shield_health += shield_regen_rate * delta
		else:
			shield_health = max_shield_health

#every time the ship is low on health, it will run this function
#it chooses between different ship events
func background():
	await get_tree().create_timer(1).timeout
	if ship_health <= 80:
		var randomvalue = rng.randi_range(1, pow(ship_health, 2))
		if randomvalue <= 80:
			var shipstatusnum
			rng.randomize()
			shipstatusnum = rng.randi_range(1,10)
#			if shipstatusnum <= 3 and ship_dark_status == false:
#				ship_dark_status = true
#				get_node("/root/Main/World/Spaceship/PowerOutage").darkevent()
#				await get_tree().create_timer(20).timeout
#			elif shipstatusnum == 4 and ship_hack_status == false:
#				ship_hack_status = true
#				get_node("/root/Main/World/hackevent").hackevent()
#				await get_tree().create_timer(20).timeout
			if shipstatusnum > 0 and ship_fire_status == "not":
				ship_fire_status = "firespreading"
				startfire()
				await get_tree().create_timer(20).timeout
	background()

func randomroom():
	rng.randomize()
	random_room = rng.randi_range(1,8)


func spreadfire(roomnum):
	var fire = fire_scene.instantiate()
	label_array.append(fire)
	if ship_fire_status == "firespreading":
		firespawnpoint = "R"+str(roomnum)+"F0"
		fire.position = get_node("FireSpawnPoints/" + firespawnpoint).position
		add_child(fire)
		if roomnum <= 4:
			for i in 20:
				if ship_fire_status == "firespreading":
					fire.get_node("fire").set_emission_rect_extents(Vector2(2*(i+1),1))
					fire.get_node("smoke").set_emission_rect_extents(Vector2((2*(i+1)+20),1))
					fire.get_node("firelight").set_energy(i*.025+.7)
					await get_tree().create_timer(1).timeout
		elif roomnum > 4 and roomnum <= 7:
			for i in 50:
				if ship_fire_status == "firespreading":
					fire.get_node("fire").set_emission_rect_extents(Vector2(2*(i+1),1))
					fire.get_node("smoke").set_emission_rect_extents(Vector2((2*(i+1)+20),1))
					fire.get_node("firelight").set_energy(i*.025+.7)
					await get_tree().create_timer(.5).timeout
		else:
			for i in 8:
				if ship_fire_status == "firespreading":
					fire.get_node("fire").set_emission_rect_extents(Vector2(2*(i+1),1))
					fire.get_node("smoke").set_emission_rect_extents(Vector2((2*(i+1)+20),1))
					fire.get_node("firelight").set_energy(i*.025+.7)
					await get_tree().create_timer(2).timeout
		await get_tree().create_timer(15).timeout
		firerooms[roomnum - 1] = "yes"
		if firerooms != ["yes","yes","yes","yes","yes","yes","yes","yes"]:
			startfire()

func startfire():
	randomroom()
	if firerooms[random_room-1] == "no":
		spreadfire(random_room)
	elif firerooms == ["yes","yes","yes","yes","yes","yes","yes","yes"]:
		print("y'all bad")
	else:
		startfire()


func stopfire():
	ship_fire_status = "firestopping"
	for door in doors:
		print(door)
		door.door_close()
	await get_tree().create_timer(1).timeout
	for n in label_array.size():
		stopfireend(n)
	await get_tree().create_timer(8).timeout
	for door in doors:
		door.door_open()
	label_array = []
	await get_tree().create_timer(60).timeout
	ship_fire_status = "not"
	for i in 8:
		firerooms[i] = "no"


func stopfireend(fire_num):
	var fire = label_array[fire_num]
	var fire_size_energy = fire.get_node("firelight").get_energy()
	var fire_size_fire_emission = fire.get_node("fire").get_emission_rect_extents().x
	var fire_size_smoke_emission = fire.get_node("smoke").get_emission_rect_extents().x
	while fire_size_energy > .7:
		fire.get_node("fire").set_emission_rect_extents(Vector2(fire_size_fire_emission-4,1))
		fire.get_node("smoke").set_emission_rect_extents(Vector2(fire_size_smoke_emission-4,1))
		fire.get_node("firelight").set_energy(fire_size_energy - .05)
		fire_size_energy = fire.get_node("firelight").get_energy()
		fire_size_fire_emission = fire.get_node("fire").get_emission_rect_extents().x
		fire_size_smoke_emission = fire.get_node("smoke").get_emission_rect_extents().x
		await get_tree().create_timer(.2).timeout
	fire.get_node("fire").emitting = false
	fire.get_node("smoke").emitting = false
	while fire_size_energy > 0:
		fire.get_node("firelight").set_energy(fire_size_energy - .05)
		fire_size_energy = fire.get_node("firelight").get_energy()
		await get_tree().create_timer(.1).timeout
	await get_tree().create_timer(2).timeout
	fire.queue_free()
