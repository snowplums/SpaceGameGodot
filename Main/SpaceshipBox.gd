extends Area2D

var enemy = null

func _ready():
	area_entered.connect(self._on_area_entered)


func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox == null:
		return
	else:
		enemy = hitbox

func damage_ship():
	if owner.has_method("take_damage"):
		owner.take_damage(enemy.damage)
