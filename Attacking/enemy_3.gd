extends CharacterBody2D


var FLY_SPEED = 400.0

var health = 4
var damage = 10
var shotFromTurret = false
var shortest_ray_point = Vector2.ZERO
var notified = false
var death_scene = preload("res://Attacking/enemy_death.tscn")

var spawn_delay = 0.0
var finished_spawning = false

func _ready():
	$SpawnDelayTimer.wait_time = spawn_delay
	$SpawnDelayTimer.start()

func choose_point():
	$ShipDetection.target_position = Vector2(0, 1500)
	for i in range(0, 360, 5):
		$ShipDetection.rotation = deg_to_rad(i)
		if $ShipDetection.is_colliding() and $ShipDetection.get_collider().name == "ShipHurtBox":
			if global_position.distance_to($ShipDetection.get_collision_point()) < global_position.distance_to(shortest_ray_point):
				shortest_ray_point = $ShipDetection.get_collision_point()
	print(shortest_ray_point)
	notify()

func slowed(pressed):
	if pressed:
		FLY_SPEED = 70.0
	else:
		FLY_SPEED = 400.0

func notify():
	#Play Audio Cue
	if $NotifySound.playing == false:
		$NotifySound.pitch_scale = randf_range(1, 1.1)
		$NotifySound.play()
	#Spawn particles in direction
	rotation = global_position.angle_to_point(shortest_ray_point)
	$NotifyParticles.angle_min = -(rad_to_deg(global_position.angle_to_point(shortest_ray_point)))
	$NotifyParticles.angle_max = -(rad_to_deg(global_position.angle_to_point(shortest_ray_point)))
	$NotifyParticles.emitting = true
	await get_tree().create_timer(2.5).timeout
	if $ChargeSound.playing == false:
		$ChargeSound.pitch_scale = randf_range(1, 1.1)
		$ChargeSound.play()
	notified = true

#func _draw():
#	#Creates dotted line in direction of attack (not needed)
#	if notified:
#		draw_circle((shortest_ray_point-position).rotated(-rotation), 2, Color.WHITE_SMOKE)
#		draw_dashed_line(Vector2(), (shortest_ray_point-position).rotated(-rotation), Color.WHITE_SMOKE, 2)
	
func _physics_process(_delta):
	if finished_spawning:
		if notified:
			velocity = position.direction_to(shortest_ray_point) * FLY_SPEED
			if get_last_slide_collision():
				attack()
			move_and_slide()
			check_health()

func check_health():
	if health <= 0:
		Global.enemies_left -= 1
		var dead = death_scene.instantiate()
		dead.global_position = global_position
		get_parent().add_child(dead)
		queue_free()

func attack():
	get_node("/root/Main/World/Spaceship").take_damage_direct(damage)
	Global.enemies_left -= 1
	var dead = death_scene.instantiate()
	dead.global_position = get_last_slide_collision().get_position()
	get_parent().add_child(dead)
	queue_free()

#on_animation_finished():
#queue_free()

func take_damage(hitbox) -> void:
	if hitbox.shotFromTurret:
		$HurtSFX.play()
		health -= hitbox.damage


func _on_spawn_delay_timer_timeout():
	choose_point()
	finished_spawning = true
