extends Control

var max_ship_health = 100

@onready var progress_bar = $CanvasLayer/ProgressBar
@onready var spaceship = get_node("/root/Main/World/Spaceship")
#@onready var door_array = get_tree().get_nodes_in_group("Door") if needed to close all doors, iterate, play close animation

# Called when the node enters the scene tree for the first time.
func _ready():
	progress_bar.value = max_ship_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	progress_bar.value = spaceship.ship_health
