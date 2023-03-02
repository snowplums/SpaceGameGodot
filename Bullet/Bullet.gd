extends CharacterBody2D

@export var speed = 1000

@export var smokeScene : PackedScene
@export var bulletImpact : PackedScene

var direction = Vector2.ZERO

func _ready():
	pass

func set_speed(new_speed):
	speed = new_speed

func set_damage(new_damage):
	$HitBox.damage = new_damage

func shot_from_turret(new_value):
	$HitBox.shotFromTurret = new_value

func _physics_process(delta):
	velocity = direction * speed * delta
	var collisionResult = move_and_collide(velocity)
	if collisionResult != null:
		$Trail2D.trail = false
		AudioManager.play_sound(global_position, "HurtSound")
		var smoke = smokeScene.instantiate() as GPUParticles2D
		get_parent().add_child(smoke)
		smoke.global_position = collisionResult.get_position()
		smoke.rotation = collisionResult.get_normal().angle()
		
		var impact = bulletImpact.instantiate() as Node2D
		get_parent().add_child(impact)
		impact.global_position = collisionResult.get_position()
		impact.rotation = collisionResult.get_normal().angle()
		queue_free()

func bullet_hit():
	$Trail2D.trail = false
	AudioManager.play_sound(global_position, "HurtSound")
	var smoke = smokeScene.instantiate() as GPUParticles2D
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	smoke.rotation = rotation
		
#	var impact = bulletImpact.instantiate() as Node2D
#	get_parent().add_child(impact)
#	impact.global_position = global_position
#	impact.rotation = rotation
	queue_free()


func _on_delete_timer_timeout():
	queue_free()
