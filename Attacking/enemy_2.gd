extends CharacterBody2D


var SPEED = 150.0
var health = 20
var can_attack = false

var spawn_delay := 0.0
var finished_spawning := false
var counter := 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var death_scene = preload("res://Attacking/enemy_death.tscn")
@onready var spawn_array = get_node("/root/Main/World/FlyerPoints").get_children()
var target := Vector2.ZERO
var offset := Vector2.ZERO
var random_num := 0
var rng = RandomNumberGenerator.new() 
@onready var wander_timer = $WanderTimer

const bullet = preload("res://Bullet/Bullet.tscn")
@export var damage = 10
@export var bullet_speed = 1000

var checks = 0

func _ready():
	$SpawnDelayTimer.wait_time = spawn_delay
	$SpawnDelayTimer.start()

func slowed(pressed):
	if pressed:
		SPEED = 20.0
	else:
		SPEED = 150.0

func detect_point():
	checks += 1
	if multiplayer.get_unique_id() == 1:
		wander_timer.wait_time = rng.randf_range(2, 6)
		var random = rng.randi_range(0, spawn_array.size()-1)
		target = spawn_array[random].position
		var space_state = get_world_2d().direct_space_state
		var rayparamters = PhysicsRayQueryParameters2D.create(self.position, target)
		offset = Vector2(rng.randi_range(-35,35), rng.randi_range(-35,35))
		var result = space_state.intersect_ray(rayparamters)
		random_num = rng.randi_range(1, 2)
		if checks < 8 and result:
			detect_point()
		else:
			checks = 0
			finished_spawning = true
			rpc("send_enemy_data", target, offset, random_num, finished_spawning)
			wander_timer.start()

@rpc("any_peer", "call_remote")
func send_enemy_data(host_target, host_offset, host_random, host_spawn_signal):
	target = host_target
	offset = host_offset
	random_num = host_random
	finished_spawning = host_spawn_signal

func _on_wander_timer_timeout():
	if multiplayer.get_unique_id() == 1:
		random_num = rng.randi_range(1, 2)
	rpc("send_enemy_data", target, offset, random_num, finished_spawning)
	rpc("enemy_attack")

@rpc("authority", "call_local")
func enemy_attack():
	if random_num == 1:
		detect_point()
	else:
		if global_position.x > 0:
			$Sprite2D.flip_h = true
		else:
			$Sprite2D.flip_h = false
		await get_tree().create_timer(0.3).timeout
		attack()

func attack():
	global_position.direction_to(Vector2.ZERO).angle()
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotate(position.angle_to_point(Vector2.ZERO))
	bullet_instance.set_damage(damage)
	bullet_instance.shot_from_turret(false)
	bullet_instance.set_speed(bullet_speed)
	bullet_instance.collision_mask = 0
	bullet_instance.direction = (Vector2.ZERO - global_position).normalized()
	get_node("/root/Main/Objects").add_child(bullet_instance)
	$ShootSFX.play()

func _physics_process(_delta):
	if finished_spawning:
		counter += 1
		$Sprite2D.position.y = 2 * sin(counter/12)
		$Lights.position.y = 2 * sin(counter/12)
		if health <= 0:
			can_attack = false
			var dead = death_scene.instantiate()
			dead.global_position = global_position
			get_parent().add_child(dead)
			Global.enemies_left -= 1
			queue_free()
		if position.distance_to(target + offset) > 5:
			velocity = position.direction_to(target + offset) * SPEED
			if velocity.x > 0:
				$Sprite2D.flip_h = false
			else:
				$Sprite2D.flip_h = true
		else:
			velocity = Vector2.ZERO

		move_and_slide()

func take_damage(hitbox) -> void:
	if hitbox.shotFromTurret:
		$HurtSFX.play()
		health -= hitbox.damage


func _on_spawn_delay_timer_timeout():
	rng.randomize()
	detect_point()
