extends CharacterBody2D


const SPEED = 150.0
var health = 10
var can_attack = false

var spawn_delay := 0.0
var finished_spawning := false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var spawn_array = get_node("/root/Main/World/FlyerPoints").get_children()
var random_num := 0
var rng = RandomNumberGenerator.new() 
@onready var wander_timer = $WanderTimer

const bullet = preload("res://Bullet/Bullet.tscn")
@export var damage = 10
@export var bullet_speed = 1000

@onready var body_parts = [$Sprite2D4, $Sprite2D3, $Sprite2D2, $Sprite2D]
var position_history = []
const GAP = 40
var patrol_points
var patrol_index = 0

func _ready():
	$SpawnDelayTimer.wait_time = spawn_delay
	$SpawnDelayTimer.start()

@rpc("any_peer", "call_remote")
func send_enemy_data(host_random, host_spawn_signal):
	random_num = host_random
	finished_spawning = host_spawn_signal

func _on_wander_timer_timeout():
	rpc("enemy_attack")

@rpc("authority", "call_local")
func enemy_attack():
	if random_num == 2:
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
	get_node("/root/Main/Network").add_child(bullet_instance)

func _physics_process(_delta):
	if finished_spawning:
		if health <= 0:
			can_attack = false
			Global.enemies_left -= 1
			queue_free()
		
		#Move along path
		var target = patrol_points[patrol_index]
		if position.distance_to(target) < 1:
			patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
			target = patrol_points[patrol_index]
		velocity = (target - position).normalized() * SPEED
		move_and_slide()
		
		#Worm-like movement code
		position_history.insert(0, $Sprite2D5.global_transform)
		
		#Move each body part
		var index := 0
		for body in body_parts:
			var point = position_history[min(index * GAP, position_history.size() - 1)]
			body.global_transform = point
			index += 1

func take_damage(hitbox) -> void:
	if hitbox.shotFromTurret:
		health -= hitbox.damage


func _on_spawn_delay_timer_timeout():
	patrol_points = get_parent().get_parent().curve.get_baked_points()
	finished_spawning = true
