extends Control

var max_ship_health = 100

@onready var ship_health_bar = $CanvasLayer/ShipHealthBar
@onready var player_health_bar = $CanvasLayer/PlayerHealthBar
@onready var player_name = $CanvasLayer/Label
@onready var spaceship = get_node("/root/Main/World/Spaceship")

var username = ""
#@onready var door_array = get_tree().get_nodes_in_group("Door") if needed to close all doors, iterate, play close animation

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer.visible = true
	ship_health_bar.value = max_ship_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	ship_health_bar.value = spaceship.ship_health
	player_name.text = username
