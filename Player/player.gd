extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -300.0
const bullet = preload("res://spaceship/bullet.tscn")

@onready var camera = $Camera2D
@onready var synchronizer = $MultiplayerSynchronizer
@onready var label = $Name
@onready var sprite = $AnimatedSprite2D
@onready var raycast = $RayCast2D
@onready var miner = get_tree().get_root().get_node("Main/World/Spaceship/Miners/Copper Miner")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var username = ""


var can_move = true
var on_turret = false
var host = null
var can_fire = true
var fire_rate = 0.2
var bullet_speed = 1000
var turret_scene = null


func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())


func _ready():
	if synchronizer.is_multiplayer_authority():
		label.visible = false
	camera.current = synchronizer.is_multiplayer_authority()


func _physics_process(delta):
	check_radius()
	if on_turret and synchronizer.is_multiplayer_authority():
		turret()
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

func turret():
	if turret_scene.in_use == true:
		turret_scene.look_at(get_global_mouse_position())
		if Input.is_action_pressed("ui_accept"):
			on_turret = false
			turret_scene.in_use = false
			turret_scene.active = false
		if Input.is_action_pressed("left_click") and can_fire:
			rpc("turret_fire")
			can_fire = false
			await get_tree().create_timer(fire_rate).timeout
			can_fire = true

func on_turret_activate(turret_node):
	on_turret = true
	turret_scene = turret_node

@rpc(any_peer, call_local)
func turret_fire():
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = turret_scene.get_global_position()
	bullet_instance.rotation = turret_scene.rotation
	bullet_instance.apply_impulse(Vector2(bullet_speed, 0).rotated(turret_scene.rotation), Vector2())
	get_node("/root/Main/Network").add_child(bullet_instance)
