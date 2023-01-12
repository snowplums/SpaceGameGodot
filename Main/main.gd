extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()

var port = 9999
var address = "127.0.0.1"
var username = "player"
var host = null
var game_running = false



func _ready():
	$Lobby.visible = true


func create_player(peer_id = 1):
	var player_character = preload("res://Player/player.tscn").instantiate()
	player_character.name = str(peer_id)
	username = $Lobby/CenterContainer/VBoxContainer/GridContainer/NameTextBox.text
	if peer_id == 1:
		player_character.is_host = true
	else:
		player_character.is_host = false
	$Network.add_child(player_character)
	rpc("change_player_name", peer_id)


func destroy_player(peer_id):
	# Delete this peer's node.
	$Network.get_node(str(peer_id)).queue_free()


func _on_host_btn_pressed():
	$Lobby.visible = false
	port = str($Lobby/CenterContainer/VBoxContainer/GridContainer/PortTextBox.text).to_int()
	address = $Lobby/CenterContainer/VBoxContainer/GridContainer/IPTextBox.text
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	# Listen to peer connections, and create new player for them
	multiplayer.peer_connected.connect(func(id): create_player(id))
	# Listen to peer disconnections, and destroy their players
	multiplayer.peer_disconnected.connect(func(id): destroy_player(id))
	
	game_running = true
	create_player()


func _on_join_btn_pressed():
	$Lobby.visible = false
	port = str($Lobby/CenterContainer/VBoxContainer/GridContainer/PortTextBox.text).to_int()
	address = $Lobby/CenterContainer/VBoxContainer/GridContainer/IPTextBox.text
	username = $Lobby/CenterContainer/VBoxContainer/GridContainer/NameTextBox.text
	multiplayer_peer.create_client(address, port)
	multiplayer.multiplayer_peer = multiplayer_peer

@rpc(any_peer, call_local, reliable, 1)
func change_player_name(peer_id):
	host = get_node("/root/Main/Network").get_node(str(peer_id))
	host.label.text = username
