class_name HitBox
extends Area2D

@export var penetration = 1
@export var damage := 10
@export var shotFromTurret = true

func _process(_delta):
	if penetration == 0:
		get_parent().bullet_hit()

func _init() -> void:
	collision_layer = 2
	collision_mask = 4
	

