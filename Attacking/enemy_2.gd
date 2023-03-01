extends CharacterBody2D


const SPEED = 150.0
var health = 10
var can_attack = false

var spawn_delay = 0.0
var finished_spawning = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var spawn_array = get_node("/root/Main/World/FlyerPoints").get_children()
var target
var offset
var rng = RandomNumberGenerator.new() 
@onready var wander_timer = $WanderTimer

const bullet = preload("res://Bullet/Bullet.tscn")
@export var bullet_damage = 10
@export var bullet_speed = 1000

func _ready():
	$SpawnDelayTimer.wait_time = spawn_delay
	$SpawnDelayTimer.start()

func detect_point():
	if multiplayer.get_unique_id() == 1:
		wander_timer.wait_time = rng.randf_range(2, 6)
		var random = rng.randi_range(0, spawn_array.size()-1)
		target = spawn_array[random]
		var space_state = get_world_2d().direct_space_state
		var rayparamters = PhysicsRayQueryParameters2D.create(self.position, target.position)
		offset = Vector2(rng.randi_range(-15,15), rng.randi_range(-15,15))
		var result = space_state.intersect_ray(rayparamters)
		if result:
			detect_point()
		else:
			wander_timer.start()

func _on_wander_timer_timeout():
	var random = rng.randi_range(1, 2)
	if random == 1:
		detect_point()
	else:
		attack()

func attack():
	global_position.direction_to(Vector2.ZERO).angle()
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotate(position.angle_to_point(Vector2.ZERO))
	bullet_instance.set_damage(bullet_damage)
	bullet_instance.shot_from_turret(false)
	bullet_instance.set_speed(bullet_speed)
	bullet_instance.collision_mask = 0
	bullet_instance.direction = (Vector2.ZERO - global_position).normalized()
	get_node("/root/Main/Network").add_child(bullet_instance)

func _physics_process(_delta):
	if finished_spawning:
		if health <= 0:
			can_attack = false
			Global.enemies_left -= 1
			queue_free()
		if position.distance_to(target.position + offset) > 5:
			velocity = position.direction_to(target.position + offset) * SPEED
		else:
			velocity = Vector2.ZERO

		move_and_slide()

func take_damage(hitbox) -> void:
	if hitbox.shotFromTurret:
		health -= hitbox.damage


func _on_spawn_delay_timer_timeout():
	rng.randomize()
	detect_point()
	finished_spawning = true
