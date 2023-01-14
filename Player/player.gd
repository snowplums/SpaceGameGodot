extends CharacterBody2D


var SPEED = 120.0
const JUMP_VELOCITY = -300.0
const bullet = preload("res://spaceship/bullet.tscn")

@onready var camera = $Camera2D
@onready var synchronizer = $MultiplayerSynchronizer
@onready var label = $Name
@onready var sprite = $AnimatedSprite2D
@onready var raycast = $RayCast2D
@onready var miner = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Miner")
@onready var crusher = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Crusher")
@onready var smelter = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Smelter")
@onready var ship_inventory = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Inventory")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var username = ""
var is_host

var can_move = true
var host = null

#Miner variables
var geode_amt = 0
var crushed_copper_amt = 0
var smelted_copper_amt = 0

var max_geode_amt = 1
var max_crushed_copper_amt = 1
var max_smelted_copper_amt = 1


func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())


func _ready():
	if synchronizer.is_multiplayer_authority():
		label.visible = false
	camera.current = synchronizer.is_multiplayer_authority()


func _physics_process(delta):
	#print(geode_amt)
	check_radius()
	if synchronizer.is_multiplayer_authority() and (geode_amt > 0 or crushed_copper_amt > 0 or smelted_copper_amt > 0):
		SPEED = 60
	else:
		SPEED = 120
	# Add the gravity.
	if synchronizer.is_multiplayer_authority() and can_move:
		if not is_on_floor():
			velocity.y += gravity * delta

		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			if direction > 0:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
			sprite.animation = "run"
			velocity.x = direction * SPEED
		else:
			if velocity.y == 0:
				sprite.animation = "idle"
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y < 0:
			sprite.animation = "jump_up"
		elif velocity.y > 0:
			sprite.animation = "jump_down"
		
		move_and_slide()
	elif synchronizer.is_multiplayer_authority() and !can_move:
		sprite.animation = "idle"
		if not is_on_floor():
			velocity.y += gravity * delta
			
		move_and_slide()

func check_radius():
	if raycast.is_colliding() and synchronizer.is_multiplayer_authority():
		if raycast.get_collider().name == "MinerRadius":
			miner.in_radius = true
		if raycast.get_collider().name == "TurretRadius":
			raycast.get_collider().get_parent().in_radius = true
		if raycast.get_collider().name == "CrusherRadius":
			crusher.in_radius = true
		if raycast.get_collider().name == "SmelterRadius":
			smelter.in_radius = true
		if raycast.get_collider().name == "InventoryRadius":
			ship_inventory.in_radius = true
