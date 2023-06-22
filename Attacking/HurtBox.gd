class_name HurtBox
extends Area2D


func _init() -> void:
	collision_layer = 12
	collision_mask = 2

func _ready() -> void:
	area_entered.connect(self._on_area_entered)
	#body_entered.connect(self._on_body_entered)

func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox == null or get_parent() == null:
		return
	
	if get_parent().has_method("take_damage"):
		if hitbox.shotFromTurret == true:
			hitbox.penetration -= 1
		get_parent().take_damage(hitbox)

#func _on_body_entered(body: CharacterBody2D) -> void:
#	print(body)
#	if body == null:
#		return
#
#	if body.is_in_group("bullet"):
#		print("hit")
#		if get_parent().has_method("take_damage"):
#			get_parent().take_damage(body)
#			if body.shotFromTurret == true:
#				body.penetration -= 1
