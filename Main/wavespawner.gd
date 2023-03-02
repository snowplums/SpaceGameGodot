extends Node2D

@onready var enemy_1 = preload("res://Attacking/enemy_1.tscn")
@onready var enemy_2 = preload("res://Attacking/enemy_2.tscn")
@onready var enemy_3 = preload("res://Attacking/enemy_3.tscn")
@onready var enemy_type = [enemy_1, enemy_2, enemy_3]

@export var enemy_1_cost = 1
@export var enemy_2_cost = 2
@export var enemy_3_cost = 3

@onready var spawn_array = get_tree().get_nodes_in_group("EnemySpawnPoints")
@onready var wavetimer = $WaveTimer
@export var spawnposition = Vector2(100,100)
var spawn_delay = 0.0

var current_planet = 1 #1 is Gaia (tropical wet), #2 is Piyama (mars), #3 is Myria (moon), #4 is Odradus (gas giant), #5 is Cryovia (ice)

var wave_number = 0
var max_wave_credits = 5
var wave_credits = max_wave_credits

func _process(_delta):
	if get_parent().game_running and wavetimer.time_left == 0 and Global.enemies_left == 0:
		print("started wave")
		wavetimer.start()

func spawn_enemy(enemy_num):
	choose_spawn()
	rpc("send_spawn_position", spawnposition)
	rpc("spawn_enemy_all", enemy_num)

func choose_spawn():
	randomize()
	spawnposition = spawn_array[randi() % spawn_array.size()].position
	spawn_delay = randf_range(3, 20)

@rpc("authority", "call_local")
func spawn_enemy_all(enemy_num):
	Global.enemies_left += 1
	var enemy_instance = enemy_type[enemy_num-1].instantiate()
	if current_planet == 1:
		enemy_instance.health += 10
	elif current_planet == 2:
		enemy_instance.health += 20
	elif current_planet == 3:
		enemy_instance.health += 30
	elif current_planet == 4:
		enemy_instance.health += 40
	elif current_planet == 5:
		enemy_instance.health += 50
	enemy_instance.position = spawnposition
	enemy_instance.spawn_delay = spawn_delay
	get_node("/root/Main/Objects").add_child(enemy_instance)

#call_local makes function apply to host aswell, call_remote makes it so only on others (not on host)

@rpc("any_peer", "call_remote")
func send_spawn_position(pos):
	spawnposition = pos


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
		print("wave spawning ended")
		wave_number += 1
		max_wave_credits += 1
		wave_credits = max_wave_credits
