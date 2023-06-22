extends ParallaxBackground

var bg_speed = 20
@onready var fire1 = get_node("/root/Main/World/Spaceship/SpaceshipSprite/Fire")
@onready var fire2 = get_node("/root/Main/World/Spaceship/SpaceshipSprite/Fire2")
@onready var fire3 = get_node("/root/Main/World/Spaceship/SpaceshipSprite/Fire3")
var bg1 = preload("res://Assets/Ship Directory/Backgrounds/purplespace.png")
var bg2 = preload("res://Assets/Ship Directory/Backgrounds/orangespace.png")
var bg3 = preload("res://Assets/Ship Directory/Backgrounds/greenspace.png")
var bg4 = preload("res://Assets/Ship Directory/Backgrounds/goldspace.png")
var bg5 = preload("res://Assets/Ship Directory/Backgrounds/bluespace.png")
var backgrounds = [bg1, bg2, bg3, bg4, bg5]

@onready var gadget_selection = preload("res://Spaceship/GadgetTable/gadget_selection.tscn")

func _process(delta):
	scroll_base_offset -= Vector2(bg_speed, 0) * delta

func travel_to_next_planet():
	$AnimationTimer.start()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "bg_speed", 4000, 11.5)
	fire1.speed_scale = 4
	fire1.scale = Vector2(0.16, 0.16)
	fire2.speed_scale = 4
	fire2.scale = Vector2(0.16, 0.16)
	fire3.speed_scale = 4
	fire3.scale = Vector2(0.16, 0.16)


func _on_animation_timer_timeout():
	$CanvasLayer/AnimationPlayer.play("change")
	fire1.speed_scale = 1.5
	fire1.scale = Vector2(0.125, 0.125)
	fire2.speed_scale = 1.5
	fire2.scale = Vector2(0.125, 0.125)
	fire3.speed_scale = 1.5
	fire3.scale = Vector2(0.125, 0.125)
	bg_speed = 20
	$"Layer 1/Sprite2D".texture = backgrounds[Global.current_planet - 1]
	$CanvasLayer/AnimationPlayer.play_backwards("change")
	
	#Gadget select after planet
	await get_tree().create_timer(1).timeout
	var gadget_scene = gadget_selection.instantiate()
	get_node("/root/Main").add_child(gadget_scene)
