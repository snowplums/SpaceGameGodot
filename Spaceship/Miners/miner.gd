extends Node2D

@onready var synchronizer = $MultiplayerSynchronizer
@export var copper = 0
@export var active = false

var in_radius = false
var miner_ui = preload("res://UI/Miners/copper_minerUI.tscn")
var host = null

var geode = 0
var max_geode_capacity = 1

@export var upg_eff_cost = 10
@export var wait_time = 1.5

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		in_radius = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		in_radius = false

func start_mining():
	if geode != max_geode_capacity:
		$AnimatedSprite2D.play("start")
		$GeodeTimer.start()
	
func _ready():
	start_mining()

func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E") and geode >= 1:
		rpc("grab_geode")
		#host.can_move = false (if want animation to play make it so player cant move)

@rpc(any_peer, call_local, reliable, 1)
func grab_geode():
	synchronizer.set_multiplayer_authority(multiplayer.get_remote_sender_id())
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	if host.geode_amt < host.max_geode_amt:
		$AnimatedSprite2D.play("idle")
		geode -= 1
		start_mining()
		host.geode_amt += 1

func _on_geode_timer_timeout():
	geode += 1
	if geode != max_geode_capacity:
		start_mining()
