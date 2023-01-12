extends CharacterBody2D


const SPEED = 300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var target = get_node("/root/Main/World/Spaceship/EnemyTarget")

var health = 50
var damage = 10
var in_radius = false
var can_attack = true
var attack_rate = 2.5

@onready var raycast_array = [$ShipDetection/RayCast2D1, $ShipDetection/RayCast2D2, $ShipDetection/RayCast2D3, $ShipDetection/RayCast2D4]

func _physics_process(_delta):
	velocity = position.direction_to(target.position) * SPEED
	move_and_slide()
	if health <= 0:
		queue_free()
	check_radius()
	if in_radius:
		look_at(target.position)
		attack()

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
	if can_attack:
		get_node("/root/Main/World/Spaceship").take_damage(damage)
		can_attack = false
		await get_tree().create_timer(attack_rate).timeout
		can_attack = true


