extends Node2D

var ship_health = 100
var fire_scene = preload("res://Spaceship/fire.tscn")
var firespawnpoint
var rng = RandomNumberGenerator.new()
var ship_status = "good"
var random_room
var firerooms = ["no","no","no","no","no","no","no","no"]

func take_damage(damage):
	if multiplayer.get_unique_id() == 1:
		print("took damage")
		rpc("update_damage", damage)

@rpc(authority, call_local)
func update_damage(damage):
	print(multiplayer.get_remote_sender_id())
	var new_ship_health = ship_health - damage
	ship_health = new_ship_health
	if ship_health < 0:
		ship_health = 0




func _ready():
	firebackground()
#this means that instead of being instantly less than 30 your fire starts
#there is an increased chance of fire each second the lower your hp
#subject to balance (rn roughly one fire every  2 minute with 80 health, one fire every 30 seconds with 40 health
func firebackground():
	await get_tree().create_timer(1).timeout
	if ship_health <= 80 and ship_status == "good":
		var randomvalue = rng.randi_range(1, pow(ship_health, 2))
		if randomvalue <= 100:
			ship_status = "firespreading"
			startfire()
	firebackground()

func randomroom():
	rng.randomize()
	random_room = rng.randi_range(1,8)
	
	
func spreadfire(roomnum):
	var fire = fire_scene.instantiate()
	if ship_status == "firespreading":
		firespawnpoint = "R"+str(roomnum)+"F0"
		fire.position = get_node("FireSpawnPoints/" + firespawnpoint).position
		add_child(fire)
	if roomnum <= 4:
		for i in 20:
			if ship_status == "firespreading":
				fire.get_node("fire").set_emission_rect_extents(Vector2(2*(i+1),1))
				fire.get_node("smoke").set_emission_rect_extents(Vector2((2*(i+1)+20),1))
				fire.get_node("firelight").set_energy(i*.05+.25)
				await get_tree().create_timer(1).timeout
	elif roomnum > 4 and roomnum <= 7:
		for i in 50:
			if ship_status == "firespreading":
				fire.get_node("fire").set_emission_rect_extents(Vector2(2*(i+1),1))
				fire.get_node("smoke").set_emission_rect_extents(Vector2((2*(i+1)+20),1))
				fire.get_node("firelight").set_energy(i*.05+.25)
				await get_tree().create_timer(.5).timeout
	else:
		for i in 8:
			if ship_status == "firespreading":
				fire.get_node("fire").set_emission_rect_extents(Vector2(2*(i+1),1))
				fire.get_node("smoke").set_emission_rect_extents(Vector2((2*(i+1)+20),1))
				fire.get_node("firelight").set_energy(i*.05+.25)
				await get_tree().create_timer(2).timeout
	await get_tree().create_timer(15).timeout
	if ship_status == "firespreading":
		firerooms[roomnum - 1] = "yes"
		startfire()

func startfire():
	randomroom()
	if firerooms[random_room-1] == "no":
		spreadfire(random_room)
	elif firerooms == ["yes","yes","yes","yes","yes","yes","yes","yes"]:
		print("y'all bad")
	else:
		startfire()
