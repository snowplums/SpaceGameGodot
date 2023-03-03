extends CanvasLayer
var hackstatus = false

func _ready():
	pass

#main function. It initiates a hack procedure for a singular player
func hackevent():
	var i = 0
	while i != 100:
		get_node("darken").self_modulate = Color(0, 0, 0, 0+.0085*i)
		i=i+1
		await get_tree().create_timer(.01).timeout
	var TW1 = create_tween()
	TW1.tween_property(get_node("darken").get_node("hackstart"), "position:y", 0, 1)
	await get_tree().create_timer(1).timeout
	var TEXTTW1 = create_tween()
	TEXTTW1.tween_property(get_node("darken").get_node("hackstart").get_node("text"),"visible_ratio", 1, 4)
	await get_tree().create_timer(8).timeout
	var TEXTTW2 = create_tween()
	TEXTTW2.tween_property(get_node("darken").get_node("hackstart").get_node("text"),"visible_ratio", 0, 2)
	await get_tree().create_timer(2).timeout
	var TW2 = create_tween()
	TW2.tween_property(get_node("darken").get_node("hackstart"), "position:y", 200, 1)
	await get_tree().create_timer(1).timeout
	var j = 0
	while j != 100:
		get_node("darken").self_modulate = Color(0, 0, 0, .85-.0085*j)
		j=j+1
		await get_tree().create_timer(.01).timeout
	hackstatus = true
	$darken.visible = true
	$hack.visible = true
	$percent.visible = true
	$martincabello.visible = true
	$speaker.visible = true
	$orangedot.visible = true
	$text.visible = true
	await get_tree().create_timer(3).timeout
	get_node("0").emitting = true
	get_node("1").emitting = true
	var n = 0
	while n != 100 and hackstatus == true:
		get_node("percent").set_text(str(n))
		get_node("percent").self_modulate = Color(1, 1-.0001*pow(n,2), 1-.0001*pow(n,2), 1)
		get_node("darken").self_modulate = Color(0, .07, 0, 0+.0095*n) 
		n = n+1
		await get_tree().create_timer(.6).timeout
	if n == 100:
		print("we should kill player here")
		hackstatus = false

#ends the hack function. Called by directly calling the function
func hackend():
	hackstatus = false
	$darken.visible = true
	var CanvasTW = create_tween()
	CanvasTW.tween_property(get_node("darken"),"self_modulate", Color(1, 1, 1, .85), 1)
	get_node("0").emitting = false
	get_node("1").emitting = false
	$martincabello.visible = false
	$speaker.visible = false
	$orangedot.visible = false
	$text.visible = false
	await get_tree().create_timer(1).timeout
	var hackTW = create_tween()
	hackTW.tween_property(get_node("hack"),"self_modulate", Color(1, 1, 1, 0), 5)
	var percentTW = create_tween()
	percentTW.tween_property(get_node("percent"),"self_modulate", Color(1, 1, 1, 0), 5)
	hackend2percentage()
	var TW1 = create_tween()
	TW1.tween_property(get_node("darken").get_node("hackend"), "position:y", 0, 1)
	await get_tree().create_timer(1).timeout
	var TEXTTW1 = create_tween()
	TEXTTW1.tween_property(get_node("darken").get_node("hackend").get_node("text"),"visible_ratio", 1, 6)
	await get_tree().create_timer(10).timeout
	var TEXTTW2 = create_tween()
	TEXTTW2.tween_property(get_node("darken").get_node("hackend").get_node("text"),"visible_ratio", 0, 2)
	await get_tree().create_timer(2).timeout
	var TW2 = create_tween()
	TW2.tween_property(get_node("darken").get_node("hackend"), "position:y", 200, 1)
	await get_tree().create_timer(1).timeout
	var TWDarken = create_tween()
	TWDarken.tween_property(get_node("darken"),"self_modulate", Color(0, 0, 0, 0), 2)
	await get_tree().create_timer(20).timeout
	get_node("/root/Main/World/Spaceship").ship_hack_status = false
	
	
#this function is required to change the percentage of the percent label
#while the hackevent is ending
func hackend2percentage():
	var n = get_node("percent").get_text()
	n = n.to_int()
	while n > 0:
		n = n-1
		$percent.text = str(n)
		await get_tree().create_timer(.3).timeout
