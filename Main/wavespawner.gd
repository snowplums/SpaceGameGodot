extends Node2D

@onready var enemy_1 = preload("res://Attacking/enemy_1.tscn")
@onready var enemy_2 = preload("res://Attacking/enemy_2.tscn")
@onready var enemy_type = [enemy_1, enemy_2]

@onready var spawn_array = get_tree().get_nodes_in_group("EnemySpawnPoints")
@onready var wavetimer = $WaveTimer
@export var spawnposition = Vector2(100,100)

var wave_credits = 5

func _process(_delta):
	if get_parent().game_running and wavetimer.time_left == 0:
		wavetimer.start()
		await wavetimer.timeout
		if multiplayer.get_unique_id() == 1:
			while wave_credits > 0:
				var rng = RandomNumberGenerator.new() 
				rng.randomize()
				var enemy_num = rng.randi_range(1, 2) #Host chooses random number from 1 to the number of enemies
				if wave_credits >= 1 and enemy_num == 1:
					spawn_enemy(enemy_num)
					wave_credits -= 1
				elif wave_credits >= 2 and enemy_num == 2:
					spawn_enemy(enemy_num)
					wave_credits -= 2




func spawn_enemy(enemy_num):
	choose_spawn()
	rpc("send_spawn_position", spawnposition)
	rpc("spawn_enemy_all", enemy_num)

func choose_spawn():
	randomize()
	spawnposition = spawn_array[randi() % spawn_array.size()].position

@rpc(authority, call_local)
func spawn_enemy_all(enemy_num):
	var enemy_instance = enemy_type[enemy_num-1].instantiate()
	enemy_instance.position = spawnposition
	get_node("/root/Main/Network").add_child(enemy_instance)

#call_local makes function apply to host aswell, call_remote makes it so only on others (not on host)

@rpc(any_peer, call_remote)
func send_spawn_position(pos):
	spawnposition = pos
