extends Node2D

@onready var synchronizer = $MultiplayerSynchronizer

var in_radius = false
var lockdown_ui = preload(insert)
var host = null

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		in_radius = true
		
func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		in_radius = false

func _process(_delta):
	if in_radius and Input.is_action_just_pressed("E"):
		var lockdown_ui_instance = lockdown_ui.instantiate()
		add_child(lockdown_ui_instance)
		host.can_move = false
		lockdown_ui_instance.host = host

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
