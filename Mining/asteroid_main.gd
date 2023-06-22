extends Node2D

var type = 0
var spawn_delay = 0
var finished_spawning = false
var speed = 0.5
const ore = preload("res://Mining/ore.tscn")
@onready var wavespawner = get_node("/root/Main/Wavespawner")
var health = 10
var rotation_speed = 0
var amount = 0

func _ready():
	if multiplayer.get_unique_id() == 1:
		speed = randf_range(0.2, 0.45)
		rotation_speed = randf_range(0.001, 0.005)
		rotation_degrees = randf_range(0,360)
		amount = randi_range(1,3)
	rpc("send_values", speed, rotation_speed, rotation_degrees, amount)
	$SpawnDelayTimer.wait_time = spawn_delay
	$SpawnDelayTimer.start()
	$AsteroidSprite.frame = type

@rpc("authority", "call_remote", "reliable")
func send_values(sent1, sent2, sent3, sent4):
	speed = sent1
	rotation_speed = sent2
	rotation_degrees = sent3
	amount = sent4


func _physics_process(_delta):
	if finished_spawning:
		position.x -= speed
		rotate(rotation_speed)


func _on_spawn_delay_timer_timeout():
	finished_spawning = true


func take_damage(hitbox):
	$Hit.play()
	$BreakParticle.restart()
	$BreakParticle.amount = 5
	$BreakParticle.emitting = true
	health -= hitbox.damage
	if health <= 0 and $AsteroidSprite.visible == true:
		wavespawner.asteroids -= 1
		$HurtBox.call_deferred("free")
		$BreakParticle.amount = 16
		$BreakParticle.emitting = true
		$Break.play()
		
		if amount > 0:
			var ore_part1 = ore.instantiate()
			ore_part1.rotate(deg_to_rad(90))
			ore_part1.position += Vector2(10,9)
			ore_part1.type = type
			ore_part1.rotation_speed = rotation_speed
			add_child(ore_part1)
		
		if amount > 1:
			var ore_part2 = ore.instantiate()
			ore_part2.rotate(deg_to_rad(180))
			ore_part2.position += Vector2(-5,-9)
			ore_part2.type = type
			ore_part2.rotation_speed = rotation_speed
			add_child(ore_part2)
		
		if amount > 2:
			var ore_part3 = ore.instantiate()
			ore_part3.rotate(deg_to_rad(270))
			ore_part3.position += Vector2(-10,8)
			ore_part3.type = type
			ore_part3.rotation_speed = rotation_speed
			add_child(ore_part3)
		
		$AsteroidSprite.visible = false
		rotation_speed = 0.0


func _on_deletion_timer_timeout():
	queue_free()
