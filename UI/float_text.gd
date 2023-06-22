extends Node2D

var text : String

func _ready():
	$Label.text = text

func _on_timer_timeout():
	queue_free()
