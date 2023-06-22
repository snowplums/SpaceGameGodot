extends CharacterBody2D


var SPEED: float = 120.0
var MAX_SPEED: float = 120.0
var CARRY_MULTIPLIER: float = 60.0
var footstep_time = 0.3
var footstep_speed = 1
var footstep_carry_speed = 0.6
const JUMP_VELOCITY = -300.0
const JUMP_BUFFER_TIME : int = 15
var jump_buffer_counter : int = 0

const dropped_item = preload("res://Player/dropped_item.tscn")

@onready var camera = $Camera2D
@onready var synchronizer = $MultiplayerSynchronizer
@onready var label = $Name
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var raycast = $RayCast2D
@onready var network = get_node("/root/Main/Network")
@onready var objects = get_node("/root/Main/Objects")
#@onready var miner = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Miner")
@onready var crusher = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Crusher")
#@onready var smelter = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Smelter")
#@onready var ship_inventory = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Inventory")
@onready var ship_directory = get_tree().get_root().get_node("Main/World/Spaceship/ShipControl")
@onready var upgrade_station = get_tree().get_root().get_node("Main/World/Spaceship/Upgrades/Upgrader")
@onready var repellent = get_tree().get_root().get_node("Main/World/Spaceship/Gadgets/Repellent")
@onready var slowdown = get_tree().get_root().get_node("Main/World/Spaceship/Gadgets/SlowDown")
@onready var orchard = get_tree().get_root().get_node("Main/World/Spaceship/Gadgets/Orchard")
@onready var ladder = get_tree().get_root().get_node("Main/World/Spaceship/Ladder")
var repellent_g
var slowdown_g
var orchard_g

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var username = ""
var is_host

var can_move = true
var top_down_mvmt = false
var on_turret = false
var host = null
var dir = Vector2.ZERO
var acceleration = 10.0

var copper = 0
var iron = 0
var platinum = 0
var gold = 0
var baitium = 0

var total = 0
var max_capacity = 4


func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())


func _ready():
	if synchronizer.is_multiplayer_authority():
		$CarryBar.visible = true
		label.visible = false
	camera.enabled = synchronizer.is_multiplayer_authority()

func update_capacity():
	if $CarryBar.value == 0:
		$CarryBar.visible = false
	else:
		$CarryBar.visible = true
	total = copper + iron + platinum + gold + baitium
	$CarryBar.max_value = max_capacity
	$CarryBar.value = total

func play_pickup_sound():
	$PickupSound.play()

func _physics_process(delta):
	check_radius()
	update_capacity()
	if synchronizer.is_multiplayer_authority() and (copper > 0 or iron > 0 or platinum > 0 or gold > 0 or baitium > 0):
		SPEED = MAX_SPEED - (CARRY_MULTIPLIER * (float(total) / max_capacity))
	else:
		SPEED = MAX_SPEED
	# Add the gravity.
	if synchronizer.is_multiplayer_authority() and can_move and top_down_mvmt == false:
		$JetpackSound.playing = false
		$JetpackParticles.emitting = false
		$Sprite2D.visible = true
		$Jetpack.visible = false
		if not is_on_floor():
			velocity.y += gravity * delta

		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept"):
			jump_buffer_counter = JUMP_BUFFER_TIME
		
		if jump_buffer_counter > 0:
			jump_buffer_counter -= 1
		
		if jump_buffer_counter > 0 and is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_buffer_counter = 0

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			if $AudioStreamPlayer2D/FootstepTimer.time_left <= 0 and is_on_floor_only():
				if(copper > 0 or iron > 0 or platinum > 0 or gold > 0 or baitium > 0):
					$AudioStreamPlayer2D.pitch_scale = randf_range(footstep_carry_speed - 0.05, footstep_carry_speed + 0.05)
					$AudioStreamPlayer2D.play()
					$AudioStreamPlayer2D/FootstepTimer.start(footstep_time)
				else:
					$AudioStreamPlayer2D.pitch_scale = randf_range(footstep_speed - 0.05, footstep_speed + 0.05)
					$AudioStreamPlayer2D.play()
					$AudioStreamPlayer2D/FootstepTimer.start(footstep_time)
			if direction > 0:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
			if anim_player.current_animation != "run":
				anim_player.play("run")
			velocity.x = direction * SPEED
		else:
			if velocity.y == 0:
				if anim_player.current_animation != "idle":
					anim_player.play("idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y < 0:
			if anim_player.current_animation != "jump_up":
				anim_player.play("jump_up")
		elif velocity.y > 0:
			if anim_player.current_animation != "jump_down":
				anim_player.play("jump_down")
		
		move_and_slide()
	elif synchronizer.is_multiplayer_authority() and !can_move:
		if anim_player.current_animation != "idle":
			anim_player.play("idle")
		if not is_on_floor():
			velocity.y += gravity * delta
	elif synchronizer.is_multiplayer_authority() and can_move and top_down_mvmt:
		get_input(delta)
			
		move_and_slide()

func get_input(delta):
	if $JetpackSound.playing == false:
		$JetpackSound.play()
	$JetpackParticles.emitting = true
	$Sprite2D.visible = false
	$Jetpack.visible = true
	velocity = Vector2.ZERO
	anim_player.play("jetpack")
	dir = Vector2.ZERO
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	dir = dir.normalized()
	
	if dir.x > 0:
		$Jetpack.flip_h = false
	elif dir.x < 0:
		$Jetpack.flip_h = true
	var targetVelocity:Vector2 = SPEED * 2 * dir
	velocity = velocity.lerp(targetVelocity, acceleration * delta)
	move_and_slide()

func check_radius():
	if raycast.is_colliding() and synchronizer.is_multiplayer_authority():
		if orchard.get_child_count() >= 1:
			orchard_g = orchard.get_child(0)
		if repellent.get_child_count() >= 1:
			repellent_g = repellent.get_child(0)
		if slowdown.get_child_count() >= 1:
			slowdown_g = slowdown.get_child(0)
#		if raycast.get_collider().name == "MinerRadius":
#			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
#			miner.in_radius = true
#		else:
#			miner.in_radius = false
		if raycast.get_collider().name == "TurretRadius":
			#raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
			raycast.get_collider().get_parent().in_radius = true
		if raycast.get_collider().name == "CrusherRadius":
			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
			crusher.in_radius = true
		else:
			crusher.in_radius = false
#		if raycast.get_collider().name == "SmelterRadius":
#			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
#			smelter.in_radius = true
#		else:
#			smelter.in_radius = false
#		if raycast.get_collider().name == "InventoryRadius":
#			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
#			ship_inventory.in_radius = true
#		else:
#			ship_inventory.in_radius = false
		if raycast.get_collider().name == "DirectoryRadius":
			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
			ship_directory.in_radius = true
		else:
			ship_directory.in_radius = false
		if raycast.get_collider().name == "UpgradeRadius":
			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
			upgrade_station.in_radius = true
		else:
			upgrade_station.in_radius = false
		for item in get_tree().get_nodes_in_group("item"):
			if raycast.get_collider().name == "ItemRadius":
				item.in_radius = true
			else:
				item.in_radius = false
		if raycast.get_collider().name == "RepellentRadius" and repellent_g != null:
			repellent_g.in_radius = true
		elif repellent_g != null:
			repellent_g.in_radius = false
		if raycast.get_collider().name == "SlowRadius" and slowdown_g != null:
			slowdown_g.in_radius = true
		elif slowdown_g != null:
			slowdown_g.in_radius = false
		if raycast.get_collider().name == "TreeRadius" and orchard_g != null:
			orchard_g.in_radius = true
		elif orchard_g != null:
			orchard_g.in_radius = false
		if raycast.get_collider().name == "BLadderRadius":
			ladder.bottom_in_radius = true
		else:
			ladder.bottom_in_radius = false
		if raycast.get_collider().name == "TLadderRadius":
			ladder.top_in_radius = true
		else:
			ladder.top_in_radius = false
		if raycast.get_collider().name == "OreRadius":
			if Global.ore_in_radius == 0:
				Global.ore_in_radius += 1
				raycast.get_collider().get_parent().in_radius = true
	elif synchronizer.is_multiplayer_authority():
		Global.ore_in_radius = 0
		ladder.top_in_radius = false
		ladder.bottom_in_radius = false
		ship_directory.in_radius = false
		for turret in get_node("/root/Main/World/Spaceship/Turrets").get_children():
			turret.in_radius = false
		for ore in get_tree().get_nodes_in_group("ore"):
			ore.in_radius = false
