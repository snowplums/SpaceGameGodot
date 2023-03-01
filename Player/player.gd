extends CharacterBody2D


var SPEED = 120.0
const JUMP_VELOCITY = -300.0

@onready var camera = $Camera2D
@onready var synchronizer = $MultiplayerSynchronizer
@onready var label = $Name
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var raycast = $RayCast2D
@onready var miner = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Miner")
@onready var crusher = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Crusher")
@onready var smelter = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Smelter")
@onready var ship_inventory = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Inventory")
@onready var ship_directory = get_tree().get_root().get_node("Main/World/Spaceship/ShipControl")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var username = ""
var is_host

var can_move = true
var on_turret = false
var host = null

#Miner variables
var geode_amt = 0
var crushed_amt = 0
var smelted_copper_amt = 0
var smelted_iron_amt = 0
var smelted_platinum_amt = 0
var smelted_gold_amt = 0
var smelted_baitium_amt = 0

var max_geode_amt = 1
var max_crushed_amt = 1
var max_smelted_amt = 1


func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())


func _ready():
	if synchronizer.is_multiplayer_authority():
		label.visible = false
	camera.enabled = synchronizer.is_multiplayer_authority()

func hold_item():
	if geode_amt >= 1:
		$MiningItems.frame = 1
		$MiningItems.visible = true
	elif crushed_amt >= 1:
		$MiningItems.frame = 0
		$MiningItems.visible = true
	elif smelted_copper_amt >= 1:
		$MiningItems.frame = 2
		$MiningItems.visible = true
	elif smelted_iron_amt >= 1:
		$MiningItems.frame = 3
		$MiningItems.visible = true
	elif smelted_platinum_amt >= 1:
		$MiningItems.frame = 4
		$MiningItems.visible = true
	elif smelted_gold_amt >= 1:
		$MiningItems.frame = 5
		$MiningItems.visible = true
	elif smelted_baitium_amt >= 1:
		$MiningItems.frame = 6
		$MiningItems.visible = true
	else:
		$MiningItems.visible = false

func _physics_process(delta):
	#print(geode_amt)
	check_radius()
	hold_item()
	if synchronizer.is_multiplayer_authority() and (geode_amt > 0 or crushed_amt > 0 or smelted_copper_amt > 0 or smelted_iron_amt > 0 or smelted_platinum_amt > 0 or smelted_gold_amt > 0 or smelted_baitium_amt > 0):
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
			if $AudioStreamPlayer2D/FootstepTimer.time_left <= 0 and is_on_floor_only():
				$AudioStreamPlayer2D.pitch_scale = randf_range(0.8, 1.2)
				$AudioStreamPlayer2D.play()
				$AudioStreamPlayer2D/FootstepTimer.start(0.3)
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
			
		move_and_slide()

func check_radius():
	if raycast.is_colliding() and synchronizer.is_multiplayer_authority():
		if raycast.get_collider().name == "MinerRadius":
			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
			miner.in_radius = true
		if raycast.get_collider().name == "TurretRadius":
			#raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
			raycast.get_collider().get_parent().in_radius = true
		if raycast.get_collider().name == "CrusherRadius":
			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
			crusher.in_radius = true
		if raycast.get_collider().name == "SmelterRadius":
			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
			smelter.in_radius = true
		if raycast.get_collider().name == "InventoryRadius":
			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
			ship_inventory.in_radius = true
		if raycast.get_collider().name == "DirectoryRadius":
			raycast.get_collider().get_parent().get_node("AnimationPlayer").play("pulse")
			ship_directory.in_radius = true
