extends CharacterBody2D


const FLY_SPEED = 100.0

var health = 50
var damage = 10
var in_radius = false
var can_attack = true
var only_once = true
var attack_rate = 2.5
var target = Vector2.ZERO

var gravity = Vector2.DOWN
var dir = 0.0 #1.0 is left and -1.0 is right
var speed = 25.0
var gravity_pow = 10.0
var jump_pow = 10.0 * 6
var jump = Vector2.ZERO
var rotation_speed = 30.0
var random
var is_attached = false

@onready var raycast_array = [$ShipDetection/RayCast2D1, $ShipDetection/RayCast2D2, $ShipDetection/RayCast2D3, $ShipDetection/RayCast2D4]
@onready var detection_array = get_node("ClosestRay").get_children()
@onready var wander_timer = $WanderTimer

func _ready():
	for raycast in detection_array:
		raycast.target_position = Vector2(0, 1000)
		if raycast.is_colliding() and raycast.get_collider().name == "ShipHurtBox":
			if raycast.global_transform.origin.distance_to(raycast.get_collision_point()) < raycast.global_transform.origin.distance_to(target):
				target = raycast.get_collision_point()

func _physics_process(delta):
	if is_on_floor():
		jump = Vector2.ZERO
	else:
		jump *= 0.9
		

	if !get_last_slide_collision():
		velocity = position.direction_to(target) * FLY_SPEED
		move_and_slide()
	else:
		if only_once:
			enemy_behavior()
			gravity = -get_last_slide_collision().get_normal()
			only_once = false
		
		if global_position.x < -260 and dir == 1:
			dir = -1
		elif global_position.x < -260 and dir == -1:
			dir = 1
		var left = gravity.rotated(deg_to_rad(90))
		velocity = ((left * dir * speed) + (gravity * gravity_pow) + jump)
		move_and_slide()
		var ret = velocity
		
		ret = get_last_slide_collision()
		if ret:
			gravity = -ret.get_normal()
			
		#rotate_body
		var a = global_transform
		var b = global_transform
		b.y = gravity
		b.x = gravity.rotated(deg_to_rad(-90))
		global_transform = a.interpolate_with(b, delta * rotation_speed)
	
	if health <= 0:
		can_attack = false
		queue_free()

func enemy_behavior():
	if multiplayer.get_unique_id() == 1:
		var rng = RandomNumberGenerator.new() 
		rng.randomize()
		random = rng.randi_range(1, 3)
		wander_timer.wait_time = rng.randf_range(1, 3)
		wander_timer.start()
		
		if random == 1:
			dir = -1
		elif random == 2:
			dir = 1
		else:
			dir = 0

func _on_wander_timer_timeout():
	enemy_behavior()

func take_damage(amount: int) -> void:
	health -= amount

func check_radius():
	var miss = 0
	for raycast in raycast_array:
		if raycast.is_colliding() and raycast.get_collider().name == "ShipHurtBox":
			in_radius = true
		else:
			miss += 1
			if miss == 4:
				in_radius = false

func attack():
	check_radius()
	if in_radius:
		if can_attack:
			get_node("/root/Main/World/Spaceship").take_damage(damage)
			can_attack = false
			await get_tree().create_timer(attack_rate).timeout
			can_attack = true
