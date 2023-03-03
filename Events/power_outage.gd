extends Node
var ship_dark_status = "light"
var lightswitch_status = "on"
var lightswitch2_status = "on"
var lightswitch3_status = "on"
var in_radius1 = false
var in_radius2 = false
var in_radius3 = false




# sets the default condition of the ship in prep for a dark event
func _ready():
	get_node("lightswitch/switch1light").visible = false
	get_node("lightswitch2/switch2light").visible = false
	get_node("lightswitch3/switch3light").visible = false
	get_node("lightswitch").set_frame(2)
	get_node("lightswitch2").set_frame(2)
	get_node("lightswitch3").set_frame(2)
	get_node("Darkness").visible = false
	background()
	
	
#detects whether levers are switched, and if all are switched the darkevent
#will end
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

#this function is run at all times to determine whether a ship's lights
#are turning on or not. If they are, this function turns on all lights
func background():
	await get_tree().create_timer(1).timeout
	if ship_dark_status == "turningon":
		ship_dark_status = "light"
		get_node("Darkness").visible = false
		get_node("lightswitch/switch1light").visible = false
		get_node("lightswitch2/switch2light").visible = false
		get_node("lightswitch3/switch3light").visible = false
		await get_tree().create_timer(30).timeout
		get_node("/root/Main/World/Spaceship").ship_dark_status = false
	background()
		
		
#this is the main function which makes the ship dark and activates levers
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

