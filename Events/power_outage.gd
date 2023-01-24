extends Node
var ship_dark_status = "light"
var lightswitch_status = "on"
var lightswitch2_status = "on"
var lightswitch3_status = "on"
var in_radius1 = false
var in_radius2 = false
var in_radius3 = false




# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("lightswitch/switch1light").visible = false
	get_node("lightswitch2/switch2light").visible = false
	get_node("lightswitch3/switch3light").visible = false
	get_node("lightswitch").set_frame(2)
	get_node("lightswitch2").set_frame(2)
	get_node("lightswitch3").set_frame(2)
	get_node("Darkness").visible = false
	background()
	
func _process(_delta):
	in_radius1 = false
	in_radius2 = false
	in_radius3 = false
	for body in get_node("lightswitch/switchradius").get_overlapping_bodies():
		if body.is_in_group("player"):
			in_radius1 = true
	for body in get_node("lightswitch2/switchradius").get_overlapping_bodies():
		if body.is_in_group("player"):
			in_radius2 = true
	for body in get_node("lightswitch3/switchradius").get_overlapping_bodies():
		if body.is_in_group("player"):
			in_radius3 = true
	if in_radius1 and Input.is_action_just_released("E") and lightswitch_status == "off":
		lightswitch_status = "on"
		get_node("lightswitch/switch1light").set_color("#59d21e")
		get_node("lightswitch").set_frame(2)
	if in_radius2 and Input.is_action_just_released("E") and lightswitch2_status == "off":
		lightswitch2_status = "on"
		get_node("lightswitch2/switch2light").set_color("#59d21e")
		get_node("lightswitch2").set_frame(2)
	if in_radius3 and Input.is_action_just_released("E") and lightswitch3_status == "off":
		lightswitch3_status = "on"
		get_node("lightswitch3/switch3light").set_color("#59d21e")
		get_node("lightswitch3").set_frame(2)

	
func background():
	await get_tree().create_timer(1).timeout
	if ship_dark_status == "turningon":
		ship_dark_status = "light"
		get_node("Darkness").visible = false
		get_node("lightswitch/switch1light").visible = false
		get_node("lightswitch2/switch2light").visible = false
		get_node("lightswitch3/switch3light").visible = false
	background()
		
func darkevent():
	get_node("Darkness").visible = true
	await get_tree().create_timer(1).timeout
	get_node("lightswitch/switch1light").visible = true
	get_node("lightswitch2/switch2light").visible = true
	get_node("lightswitch3/switch3light").visible = true
	lightswitch_status = "off"
	lightswitch2_status = "off"
	lightswitch3_status = "off"
	get_node("lightswitch/switch1light").set_color("#bc6b1e")
	get_node("lightswitch2/switch2light").set_color("#bc6b1e")
	get_node("lightswitch3/switch3light").set_color("#bc6b1e")
	get_node("lightswitch").set_frame(2)
	get_node("lightswitch2").set_frame(2)
	get_node("lightswitch3").set_frame(2)
	while lightswitch_status == "off" or lightswitch2_status == "off" or lightswitch3_status == "off":
		await get_tree().create_timer(1).timeout
	ship_dark_status = "turningon"

