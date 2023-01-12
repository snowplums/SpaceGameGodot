extends CanvasLayer

@onready var copper_label = $ColorRect/Label2
@onready var miner = get_parent()

var host = null

func _process(_delta):
	if Input.is_action_just_pressed("E"):
		miner.active = false
		host.can_move = true
		queue_free()
	copper_label.text = str(miner.copper)
	$ColorRect/UpgEff/Label2.text = str(miner.upg_eff_cost, " copper")
	$Timer.wait_time = miner.wait_time

func _on_button_pressed():
	$ColorRect/MineCopper.disabled = true
	$Timer.start()


func _on_timer_timeout():
	$ColorRect/MineCopper.disabled = false
	miner.copper += 1


func _on_upg_eff_pressed():
	if miner.copper >= miner.upg_eff_cost:
		miner.copper -= miner.upg_eff_cost
		miner.wait_time -= 0.499
		miner.upg_eff_cost = miner.upg_eff_cost * 2
