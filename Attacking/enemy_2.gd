extends CharacterBody2D


const SPEED = 150.0
var health = 10
var can_attack = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var spawn_array = get_node("/root/Main/World/FlyerPoints").get_children()
var target
var offset
var rng = RandomNumberGenerator.new() 
@onready var wander_timer = $WanderTimer

func _ready():
	rng.randomize()
	detect_point()

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
			print("started timer")
			wander_timer.start()

func _on_wander_timer_timeout():
	var random = rng.randi_range(1, 2)
	if random == 1:
		detect_point()
	else:
		attack()

func attack():
	global_position.direction_to(Vector2.ZERO).angle()

func _physics_process(_delta):
	if health <= 0:
		can_attack = false
		queue_free()
	if position.distance_to(target.position + offset) > 5:
		velocity = position.direction_to(target.position + offset) * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
