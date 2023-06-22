extends Node2D

@onready var asteroid = preload("res://Mining/asteroid.tscn")
@onready var enemy_1 = preload("res://Attacking/enemy_1.tscn")
@onready var enemy_2 = preload("res://Attacking/enemy_2.tscn")
@onready var enemy_3 = preload("res://Attacking/enemy_3.tscn")
@onready var worm_boss = preload("res://Attacking/worm_boss.tscn")
@onready var enemy_type = [enemy_1, enemy_2, enemy_3, worm_boss]

@onready var enemy_spawn_scene = preload("res://Attacking/enemy_spawn.tscn")

@export var enemy_1_cost = 1
@export var enemy_2_cost = 2
@export var enemy_3_cost = 3
@export var worm_boss_cost = 100

@onready var background = get_node("/root/Main/World/Spaceship/ParallaxBackground")
@onready var spawn_array = get_tree().get_nodes_in_group("EnemySpawnPoints")
@onready var wavetimer = $WaveTimer
@onready var asteroidtimer = $AsteroidTimer
var spawnposition = Vector2(100,100)
var spawn_delay = 0.0

var current_planet = 1 #1 is Gaia (tropical wet), #2 is Piyama (mars), #3 is Myria (moon), #4 is Odradus (gas giant), #5 is Cryovia (ice)
var current_planet_waves = 10 #Default number of waves for the starting planet, will increase by set amount each planet

var wave_number = 0
var max_wave_credits = 5 #5 default
var wave_credits = max_wave_credits

var asteroids = 0
var max_asteroids = 7
var main_offset = Vector2.ZERO

func _process(_delta):
	if get_parent().game_running and Global.enemies_left == 0:
		asteroidtimer.start()
		if wavetimer.time_left == 0:
			if wave_number <= current_planet_waves:
				print("started wave")
				wavetimer.start()

func spawn_enemy(enemy_num):
	choose_spawn()
	rpc("send_spawn_position", spawnposition)
	rpc("send_spawn_delay", spawn_delay)
	rpc("spawn_enemy_all", enemy_num)

func spawn_asteroid(asteroid_num, offset):
	choose_asteroid_spawn(offset)
	rpc("send_spawn_position", spawnposition)
	rpc("send_spawn_delay", spawn_delay)
	rpc("spawn_asteroid_all", asteroid_num)

func choose_spawn():
	randomize()
	spawnposition = spawn_array[randi() % spawn_array.size()].position
	spawn_delay = randf_range(1, 4)

func choose_asteroid_spawn(offset):
	randomize()
	spawnposition = get_parent().get_node("AsteroidPoint").position + offset

@rpc("authority", "call_local")
func spawn_enemy_all(enemy_num):
	Global.enemies_left += 1
	var enemy_instance = enemy_type[enemy_num-1].instantiate()
	var enemy_spawn = enemy_spawn_scene.instantiate()
	#if Global.current_planet == 1:
	#	enemy_instance.health += 10
	if Global.current_planet == 2:
		enemy_instance.health += 10
		enemy_instance.damage += 1
	elif Global.current_planet == 3:
		enemy_instance.health += 20
	elif Global.current_planet == 4:
		enemy_instance.health += 30
	elif Global.current_planet == 5:
		enemy_instance.health += 40
	enemy_instance.position = spawnposition
	enemy_instance.spawn_delay = spawn_delay
	enemy_spawn.position = spawnposition
	if enemy_num == 4:
		enemy_instance.position = Vector2.ZERO
		get_node("/root/Main/World/Path2D/PathFollow2D").add_child(enemy_instance)
	else:
		get_node("/root/Main/Objects").add_child(enemy_spawn)
		get_node("/root/Main/Objects").add_child(enemy_instance)

@rpc("authority", "call_local")
func spawn_asteroid_all(asteroid_num):
	print("spawned asterioid")
	var asteroid_instance = asteroid.instantiate()
	asteroid_instance.type = asteroid_num
	asteroid_instance.spawn_delay = spawn_delay
	asteroid_instance.position = spawnposition + main_offset
	get_node("/root/Main/Asteroids").add_child(asteroid_instance)
	
#call_local makes function apply to host aswell, call_remote makes it so only on others (not on host)

@rpc("any_peer", "call_remote")
func send_spawn_position(pos):
	spawnposition = pos

@rpc("any_peer", "call_remote")
func send_spawn_delay(delay):
	spawn_delay = delay


func _on_wave_timer_timeout():
	if multiplayer.get_unique_id() == 1:
		while wave_credits > 0:
			var rng = RandomNumberGenerator.new() 
			rng.randomize()
			var enemy_num = rng.randi_range(1, enemy_type.size()) #Host chooses random number from 1 to the number of enemies
			if wave_credits >= enemy_1_cost and enemy_num == 1:
				spawn_enemy(enemy_num)
				wave_credits -= enemy_1_cost
			elif wave_credits >= enemy_2_cost and enemy_num == 2:
				spawn_enemy(enemy_num)
				wave_credits -= enemy_2_cost
			elif wave_credits >= enemy_3_cost and enemy_num == 3:
				spawn_enemy(enemy_num)
				wave_credits -= enemy_3_cost
			elif wave_credits >= worm_boss_cost and enemy_num == 4:
				spawn_enemy(enemy_num)
				wave_credits -= worm_boss_cost
		print("wave spawning ended")
		wave_number += 1
		max_wave_credits += 1
		wave_credits = max_wave_credits
	if wave_number > current_planet_waves: #If wave number is past the current planet's max number of waves, unlocks the next planet
		Global.planets_unlocked += 1
		Global.stop_mining = true # No more ores made

func travel_to_planet():
	# Once button is pressed play animation
	$TravelSound.play()
	background.travel_to_next_planet()
	wave_number = 0 # Resets wave count to zero
	current_planet_waves += 1 # Each planet will have one more wave than last

func _on_asteroid_timer_timeout():
	if multiplayer.get_unique_id() == 1:
		if max_asteroids > asteroids:
			var rng = RandomNumberGenerator.new() 
			rng.randomize()
			var asteroid_num = rng.randi_range(0, 4)
			var offset_x
			var offset_y
			offset_x = rng.randf_range(-100,400)
			var random = rng.randi_range(1,2)
			if random == 1:
				offset_y = rng.randf_range(-320,-130)
			else:
				offset_y = rng.randf_range(145,320)
			var offset = Vector2(offset_x, offset_y)
			spawn_asteroid(asteroid_num, offset)
			asteroids += 1
