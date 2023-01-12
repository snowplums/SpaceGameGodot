extends Node2D

@onready var synchronizer = $MultiplayerSynchronizer
@export var copper = 0
@export var active = false

var in_radius = false
var miner_ui = preload("res://UI/Miners/copper_minerUI.tscn")
var host = null

@export var upg_eff_cost = 10
@export var wait_time = 1.5

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		in_radius = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		in_radius = false

func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E") and !active:
		rpc("miner_active")
		active = !active
		var miner_ui_instance = miner_ui.instantiate()
		add_child(miner_ui_instance)
		host.can_move = false
		miner_ui_instance.host = host

@rpc(any_peer, call_local, reliable, 1)
func miner_active():
	synchronizer.set_multiplayer_authority(multiplayer.get_remote_sender_id())
	host = get_node("/root/Main/Network").get_node(str(multiplayer.get_remote_sender_id()))
	
	
