extends Node2D

var ship_health = 100
var fire_scene = preload("res://Spaceship/fire.tscn")
var firespawnpoint
var rng = RandomNumberGenerator.new()
var ship_fire_status = "not"
var random_room
var firerooms = ["no","no","no","no","no","no","no","no"]
var label_array = []
@onready var doors = get_tree().get_nodes_in_group("Door")

func take_damage(hitbox):
	if multiplayer.get_unique_id() == 1 and hitbox.shotFromTurret == false:
		rpc("update_damage", hitbox.damage)
		hitbox.get_parent().bullet_hit()

func take_damage_direct(damage):
	if multiplayer.get_unique_id() == 1:
		rpc("update_damage", damage)

@rpc("authority", "call_local")
func update_damage(damage):
	var new_ship_health = ship_health - damage
	ship_health = new_ship_health
	if ship_health < 0:
		ship_health = 0

func _ready():
	background()
#this means that instead of being instantly less than 30 your fire starts
#there is an increased chance of fire each second the lower your hp
#subject to balance (rn roughly one fire every  2 minute with 80 health, one fire every 30 seconds with 40 health
func background():
	await get_tree().create_timer(1).timeout
	if ship_health <= 80 and ship_fire_status == "not":
		var randomvalue = rng.randi_range(1, pow(ship_health, 2))
		if randomvalue <= 100:
			ship_fire_status = "firespreading"
			startfire()
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
	await get_tree().create_timer(40).timeout
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
