extends Node2D

const HurtSound = preload("res://Assets/Sound Effects/Attacking/Hit_Hurt38.wav")

func play_sound(global_pos, sound):
	$AudioStreamPlayer2D.global_position = global_pos
	if sound == "HurtSound":
		$AudioStreamPlayer2D.pitch_scale = randf_range(0.9, 1.1)
		$AudioStreamPlayer2D.stream = HurtSound
	$AudioStreamPlayer2D.play()
