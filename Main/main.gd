extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()

var port = 9999
var address = "127.0.0.1"
var username = "player"
var host = null
var total_players = 0
var players_ready = 0
var game_running = false

func _ready():
	$MusicPlayer.play()

func _on_host_btn_pressed():
	$WaitingRoom.visible = true
	$AmbientNoise.play()
	$Lobby.visible = false
	port = str($Lobby/CenterContainer/VBoxContainer/GridContainer/PortTextBox.text).to_int()
	address = $Lobby/CenterContainer/VBoxContainer/GridContainer/IPTextBox.text
	username = $Lobby/CenterContainer/VBoxContainer/GridContainer/NameTextBox.text
	$PlayerUI.username = username
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	# Listen to peer connections, and create new player for them
	multiplayer.peer_connected.connect(func(id): create_player(id))
	# Listen to peer disconnections, and destroy their players
	multiplayer.peer_disconnected.connect(func(id): destroy_player(id))
	
	create_player()


func _on_join_btn_pressed():
	$WaitingRoom.visible = true
	$AmbientNoise.play()
	$Lobby.visible = false
	port = str($Lobby/CenterContainer/VBoxContainer/GridContainer/PortTextBox.text).to_int()
	address = $Lobby/CenterContainer/VBoxContainer/GridContainer/IPTextBox.text
	username = $Lobby/CenterContainer/VBoxContainer/GridContainer/NameTextBox.text
	$PlayerUI.username = username
	multiplayer_peer.create_client(address, port)
	multiplayer.multiplayer_peer = multiplayer_peer


func create_player(peer_id = 1):
	var player_character = preload("res://Player/player.tscn").instantiate()
	username = $Lobby/CenterContainer/VBoxContainer/GridContainer/NameTextBox.text
	player_character.name = str(peer_id)
	if peer_id == 1:
		player_character.is_host = true
	else:
		player_character.is_host = false
	$Network.add_child(player_character)
	rpc("change_player_name", peer_id)
	rpc_id(1, "add_player_count")


func destroy_player(peer_id):
	# Delete this peer's node.
	$Network.get_node(str(peer_id)).queue_free()


@rpc("any_peer", "call_local", "reliable")
func add_player_count():
	total_players = total_players + 1
	rpc("set_player_count", total_players)


@rpc("authority", "call_local", "reliable")
func set_player_count(total):
	total_players = total


func _on_ready_btn_pressed():
	#if everyone ready do this
	rpc("player_ready")
	print("ready: ", players_ready)
	print("total: ", total_players)
	if players_ready == total_players:
		rpc("start_game")


@rpc("any_peer", "call_local", "reliable")
func start_game():
	Global.total_players = total_players
	get_node("Lobby").queue_free()
	get_node("WaitingRoom").queue_free()
	game_running = true

@rpc("any_peer", "call_local", "reliable")
func player_ready():
	players_ready += 1

@rpc("any_peer", "call_local", "reliable", 1)
func change_player_name(peer_id):
	await get_tree().create_timer(1).timeout
	host = get_node("/root/Main/Network").get_node(str(peer_id))
	host.label.text = username
