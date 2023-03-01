extends Camera2D

@export var camera_zoom = 1.4
@export var turret_zoom = 1.3


const Dead_Zone = 150

func _process(_delta):
	if get_parent().on_turret:
		zoom = Vector2(turret_zoom, turret_zoom)
	else:
		zoom = Vector2(camera_zoom, camera_zoom)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and get_parent().on_turret:
		var _target = event.position - get_viewport_rect().size * 0.5
		if _target.length() < Dead_Zone:
			self.position = Vector2(0,0)
		else:
			self.position = _target.normalized() * (_target.length() -  Dead_Zone) * 0.5
	elif not get_parent().on_turret:
		self.position = Vector2.ZERO
