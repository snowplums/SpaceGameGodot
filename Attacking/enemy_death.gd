extends Node2D

func _ready():
	$DeleteTimer.start()
	$DeathParticle.restart()
	$DeathParticle.emitting = true
	$DeathParticle2.restart()
	$DeathParticle2.emitting = true
	$DeathSoundEffect.play()
	var tween = get_tree().create_tween()
	tween.tween_property($Light, "energy", 0, 0.5)


func _on_delete_timer_timeout():
	queue_free()
