extends CanvasLayer

var picked_array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	picked_array = [$TextureButton5/Picked.visible, $TextureButton4/Picked.visible, $TextureButton3/Picked.visible, $TextureButton2/Picked.visible, $TextureButton/Picked.visible]
	if picked_array.count(true) == 1:
		$GoButton.visible = true
	else:
		$GoButton.visible = false


func _on_texture_button_mouse_entered():
	$TextureButton/Selection.visible = true


func _on_texture_button_mouse_exited():
	$TextureButton/Selection.visible = false


func _on_texture_button_2_mouse_entered():
	$TextureButton2/Selection.visible = true


func _on_texture_button_2_mouse_exited():
	$TextureButton2/Selection.visible = false


func _on_texture_button_3_mouse_entered():
	$TextureButton3/Selection.visible = true


func _on_texture_button_3_mouse_exited():
	$TextureButton3/Selection.visible = false


func _on_texture_button_4_mouse_entered():
	$TextureButton4/Selection.visible = true


func _on_texture_button_4_mouse_exited():
	$TextureButton4/Selection.visible = false


func _on_texture_button_5_mouse_entered():
	$TextureButton5/Selection.visible = true


func _on_texture_button_5_mouse_exited():
	$TextureButton5/Selection.visible = false


func _on_texture_button_pressed():
	if picked_array.count(false) == 5:
		$TextureButton/Picked.visible = !$TextureButton/Picked.visible
	elif $TextureButton/Picked.visible == true:
		$TextureButton/Picked.visible = false

func _on_texture_button_2_pressed():
	if picked_array.count(false) == 5:
		$TextureButton2/Picked.visible = !$TextureButton2/Picked.visible
	elif $TextureButton2/Picked.visible == true:
		$TextureButton2/Picked.visible = false


func _on_texture_button_3_pressed():
	if picked_array.count(false) == 5:
		$TextureButton3/Picked.visible = !$TextureButton3/Picked.visible
	elif $TextureButton3/Picked.visible == true:
		$TextureButton3/Picked.visible = false


func _on_texture_button_4_pressed():
	if picked_array.count(false) == 5:
		$TextureButton4/Picked.visible = !$TextureButton4/Picked.visible
	elif $TextureButton4/Picked.visible == true:
		$TextureButton4/Picked.visible = false


func _on_texture_button_5_pressed():
	if picked_array.count(false) == 5:
		$TextureButton5/Picked.visible = !$TextureButton5/Picked.visible
	elif $TextureButton5/Picked.visible == true:
		$TextureButton5/Picked.visible = false


