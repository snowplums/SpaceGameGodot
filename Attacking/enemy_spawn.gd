extends Node2D

func _ready():
	$DeleteTimer.start()
	$SpawnNoise.play()
	$DeathParticle.restart()
	$DeathParticle.emitting = true

func _on_delete_timer_timeout():
	queue_free()
