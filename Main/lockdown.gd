extends Node2D
var in_radius = false
var cooldown = "ready"

@onready var spaceship = get_node("/root/Main/World/Spaceship")
var lockdown_reduction = 0.7 # Default 70% damage reduction

func cooldownchange():
	cooldown = "ontimer"
	$LockdownButton.set_frame(1)
	$LockdownButton/PointLight2D.visible = false
	await get_tree().create_timer(80).timeout
	cooldown = "ready"
	$LockdownButton.set_frame(0)
	$LockdownButton/PointLight2D.visible = true

func _process(_delta):
	in_radius = false
	for body in get_node("buttonradius").get_overlapping_bodies():
		if body.is_in_group("player"):
			in_radius = true
	if in_radius and Input.is_action_just_released("E") and cooldown == "ready" and Global.hasLockdown:
		spaceship.reduction = 1 - lockdown_reduction
		$ReductionDuration.start()
		cooldownchange()
		get_node("/root/Main/World/Spaceship").stopfire()


func _on_reduction_duration_timeout():
	spaceship.reduction = 1.0
