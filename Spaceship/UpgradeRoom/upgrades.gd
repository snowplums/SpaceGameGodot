extends Node
@onready var turret = get_node("/root/Main/World/Spaceship/Turrets/Turret")
@onready var inv = get_node("/root/Main/World/Spaceship/Miners/Inventory")
@onready var network = get_node("/root/Main/Network")
@onready var purchase_sound = $Purchase
@onready var fail_purchase_sound = $FailedPurchase
@onready var purchase_particles = $CanvasLayer/PurchaseParticles
const OFFSET = Vector2(32,32)
var in_radius = false
@onready var costs = [$"CanvasLayer/Stored&Cost/CopperCost", $"CanvasLayer/Stored&Cost/IronCost", $"CanvasLayer/Stored&Cost/PlatinumCost", $"CanvasLayer/Stored&Cost/GoldCost", $"CanvasLayer/Stored&Cost/BaitiumCost"]

@onready var upg_dmg = $CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgDmg
@onready var upg_miner_cap = $CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMinerCap
@onready var upg_player_cap = $CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgPlayerCap
@onready var upg_mvmtspd = $CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMvmtSpd
@onready var upg_blast_radius = $CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBlastRadius
@onready var upg_bullet_penetration = $CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBulletPenetration
@onready var upg_bullets_fired = $CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBulletsFired
@onready var upg_firerate = $CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgFirerate
@onready var upg_miner_spd = $CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMinerSpd

# Turret upgrade
var trt_upgrade_price = 1
var trt_upgrade_amount = 5

# Player capacity upgrade
var capacity_upgrade_price = 1
var capacity_price_increment = 3

# Miner capacity upgrade
var miner_cap_upgrade_price = 1
var miner_cap_price_increment = 3

# Movement speed upgrade
var mvmt_spd_upgrade_price = 1
var mvmt_spd_price_increment = 3

# Blast radius upgrade
var blast_radius_upgrade_price = 1
var blast_radius_price_increment = 3

# Bullet penetration upgrade
var bullet_pierce_upgrade_price = 1
var bullet_pierce_price_increment = 3

# Bullets fired upgrade
var bullets_fired_upgrade_price = 1
var bullets_fired_price_increment = 3

# Firerate upgrade
var firerate_upgrade_price = 1
var firerate_price_increment = 3

# Miner speed upgrade
var miner_spd_upgrade_price = 1
var miner_spd_price_increment = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Amount of materials stored
	$"CanvasLayer/Stored&Cost/CopperStored".text = str(Global.smelted_copper)
	$"CanvasLayer/Stored&Cost/IronStored".text = str(Global.smelted_iron)
	$"CanvasLayer/Stored&Cost/PlatinumStored".text = str(Global.smelted_platinum)
	$"CanvasLayer/Stored&Cost/GoldStored".text = str(Global.smelted_gold)
	$"CanvasLayer/Stored&Cost/BaitiumStored".text = str(Global.smelted_baitium)
	
	# Update costs on price tag
	upg_dmg.get_node("Price/Label").text = str(trt_upgrade_price)
	upg_miner_cap.get_node("Price/Label").text = str(miner_cap_upgrade_price)
	upg_player_cap.get_node("Price/Label").text = str(capacity_upgrade_price)
	upg_mvmtspd.get_node("Price/Label").text = str(mvmt_spd_upgrade_price)
	upg_blast_radius.get_node("Price/Label").text = str(blast_radius_upgrade_price)
	upg_bullet_penetration.get_node("Price/Label").text = str(bullet_pierce_upgrade_price)
	upg_bullets_fired.get_node("Price/Label").text = str(bullets_fired_upgrade_price)
	upg_firerate.get_node("Price/Label").text = str(firerate_upgrade_price)
	upg_miner_spd.get_node("Price/Label").text = str(miner_spd_upgrade_price)
	
	if(in_radius):
		if(Input.is_action_just_pressed("E")):
			if $CanvasLayer.visible == true:
				$Exit.play()
			else:
				$Enter.play()
			$CanvasLayer.visible=!$CanvasLayer.visible
	else:
		$CanvasLayer.visible=false


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("RESET")
		in_radius=false

# Mouse hover and mouse exit events
func _on_upg_dmg_mouse_entered():
	upg_dmg.get_node("AnimationPlayer").play("pulse")
	var tween = get_tree().create_tween()
	tween.tween_property(upg_dmg, "scale", Vector2(2.2,2.2), 0.2)
	$CanvasLayer/UpgradeTitle.text = "Upgrade Damage"
	$CanvasLayer/UpgradeTitle/Description.text = "Increases the amount of damage the ship's turret will deal"
	costs[0].text = str(trt_upgrade_price)
	$Hover.play()

func _on_upg_dmg_mouse_exited():
	upg_dmg.get_node("AnimationPlayer").play("RESET")
	var tween = get_tree().create_tween()
	tween.tween_property(upg_dmg, "scale", Vector2(2,2), 0.1)

func _on_upg_miner_cap_mouse_entered():
	upg_miner_cap.get_node("AnimationPlayer").play("pulse")
	var tween = get_tree().create_tween()
	tween.tween_property(upg_miner_cap, "scale", Vector2(2.2,2.2), 0.2)
	$CanvasLayer/UpgradeTitle.text = "Upgrade Miner Capacity"
	$CanvasLayer/UpgradeTitle/Description.text = "Increases the amount of ores the miners onboard the ship can hold"
	costs[0].text = str(miner_cap_upgrade_price)
	$Hover.play()
	
func _on_upg_miner_cap_mouse_exited():
	upg_miner_cap.get_node("AnimationPlayer").play("RESET")
	var tween = get_tree().create_tween()
	tween.tween_property(upg_miner_cap, "scale", Vector2(2,2), 0.1)

func _on_upg_player_cap_mouse_entered():
	upg_player_cap.get_node("AnimationPlayer").play("pulse")
	var tween = get_tree().create_tween()
	tween.tween_property(upg_player_cap, "scale", Vector2(2.2,2.2), 0.2)
	$CanvasLayer/UpgradeTitle.text = "Upgrade Player Capacity"
	$CanvasLayer/UpgradeTitle/Description.text = "Increases the amount of ores the player can hold"
	costs[0].text = str(capacity_upgrade_price)
	$Hover.play()
	
func _on_upg_player_cap_mouse_exited():
	upg_player_cap.get_node("AnimationPlayer").play("RESET")
	var tween = get_tree().create_tween()
	tween.tween_property(upg_player_cap, "scale", Vector2(2,2), 0.1)

func _on_upg_mvmt_spd_mouse_entered():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMvmtSpd/AnimationPlayer.play("pulse")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMvmtSpd, "scale", Vector2(2.2,2.2), 0.2)
	$CanvasLayer/UpgradeTitle.text = "Upgrade Movement Speed"
	$CanvasLayer/UpgradeTitle/Description.text = "Increases the movement speed of the player"
	costs[0].text = str(mvmt_spd_upgrade_price)
	$Hover.play()
	
func _on_upg_mvmt_spd_mouse_exited():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMvmtSpd/AnimationPlayer.play("RESET")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMvmtSpd, "scale", Vector2(2,2), 0.1)

func _on_upg_blast_radius_mouse_entered():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBlastRadius/AnimationPlayer.play("pulse")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBlastRadius, "scale", Vector2(2.2,2.2), 0.2)
	$CanvasLayer/UpgradeTitle.text = "Upgrade Blast Radius"
	$CanvasLayer/UpgradeTitle/Description.text = "Increases the blast radius of the explosive turret"
	costs[0].text = str(blast_radius_upgrade_price)
	$Hover.play()
	
func _on_upg_blast_radius_mouse_exited():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBlastRadius/AnimationPlayer.play("RESET")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBlastRadius, "scale", Vector2(2,2), 0.1)

func _on_upg_bullet_penetration_mouse_entered():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBulletPenetration/AnimationPlayer.play("pulse")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBulletPenetration, "scale", Vector2(2.2,2.2), 0.2)
	$CanvasLayer/UpgradeTitle.text = "Upgrade Bullet Piercing"
	$CanvasLayer/UpgradeTitle/Description.text = "Increases the amount of targets a bullet will pierce before breaking"
	costs[0].text = str(bullet_pierce_upgrade_price)
	$Hover.play()
	
func _on_upg_bullet_penetration_mouse_exited():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBulletPenetration/AnimationPlayer.play("RESET")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBulletPenetration, "scale", Vector2(2,2), 0.1)

func _on_upg_bullets_fired_mouse_entered():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBulletsFired/AnimationPlayer.play("pulse")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBulletsFired, "scale", Vector2(2.2,2.2), 0.2)
	$CanvasLayer/UpgradeTitle.text = "Upgrade Bullets Fired"
	$CanvasLayer/UpgradeTitle/Description.text = "Increases the number of bullets fired from the shotgun turret"
	costs[0].text = str(bullets_fired_upgrade_price)
	$Hover.play()
	
func _on_upg_bullets_fired_mouse_exited():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBulletsFired/AnimationPlayer.play("RESET")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgBulletsFired, "scale", Vector2(2,2), 0.1)

func _on_upg_firerate_mouse_entered():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgFirerate/AnimationPlayer.play("pulse")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgFirerate, "scale", Vector2(2.2,2.2), 0.2)
	$CanvasLayer/UpgradeTitle.text = "Upgrade Fire Rate"
	$CanvasLayer/UpgradeTitle/Description.text = "Increases the rate of fire of the ship's turret"
	costs[0].text = str(firerate_upgrade_price)
	$Hover.play()
	
func _on_upg_firerate_mouse_exited():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgFirerate/AnimationPlayer.play("RESET")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgFirerate, "scale", Vector2(2,2), 0.1)

func _on_upg_miner_spd_mouse_entered():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMinerSpd/AnimationPlayer.play("pulse")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMinerSpd, "scale", Vector2(2.2,2.2), 0.2)
	$CanvasLayer/UpgradeTitle.text = "Upgrade Miner Speed"
	$CanvasLayer/UpgradeTitle/Description.text = "Increases the speed at which the miners produce, crush, and smelt ores"
	costs[0].text = str(miner_spd_upgrade_price)
	$Hover.play()
	
func _on_upg_miner_spd_mouse_exited():
	$CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMinerSpd/AnimationPlayer.play("RESET")
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/ScrollContainer/Background/UpgradeBoxes/UpgMinerSpd, "scale", Vector2(2,2), 0.1)



func _on_upg_dmg_pressed():
	if(Global.ores[0] >= trt_upgrade_price):
		rpc("upgrade_turret", trt_upgrade_amount)
		purchase_sound.play()
		purchase_particles.global_position = upg_dmg.global_position + OFFSET
		purchase_particles.restart()
		purchase_particles.emitting = true
	else:
		fail_purchase_sound.play()

@rpc("any_peer", "call_local", "reliable")
func upgrade_turret(_upgrade_val):
	Global.ores[0] -= trt_upgrade_price
	print(Global.smelted_copper)
	turret.bullet_damage += trt_upgrade_amount
	trt_upgrade_price += trt_upgrade_amount
	costs[0].text = str(trt_upgrade_price)

#func _on_upg_miner_cap_pressed():
#	if(Global.ores[0] >= miner_cap_upgrade_price):
#		purchase_sound.play()
#		purchase_particles.global_position = upg_miner_cap.global_position + OFFSET
#		purchase_particles.restart()
#		purchase_particles.emitting = true
#	else:
#		fail_purchase_sound.play()

#@rpc("any_peer", "call_local", "reliable")
#func upgrade_miner_capacity():
#	pass

func _on_upg_player_cap_pressed():
	if(Global.ores[0] >= capacity_upgrade_price):
		rpc("upgrade_player_capacity")
		purchase_sound.play()
		purchase_particles.global_position = upg_player_cap.global_position + OFFSET
		purchase_particles.restart()
		purchase_particles.emitting = true
	else:
		fail_purchase_sound.play()

@rpc("any_peer", "call_local", "reliable")
func upgrade_player_capacity():
	var players = network.get_children()
	for player in players:
		player.CARRY_MULTIPLIER -= 10
		player.footstep_carry_speed += 0.1
	Global.ores[0] -= capacity_upgrade_price
	capacity_upgrade_price += capacity_price_increment
	costs[0].text = str(capacity_upgrade_price)

func _on_upg_mvmt_spd_pressed():
	if(Global.ores[0] >= mvmt_spd_upgrade_price):
		rpc("upgrade_mvmt_spd")
		purchase_sound.play()
		purchase_particles.global_position = upg_mvmtspd.global_position + OFFSET
		purchase_particles.restart()
		purchase_particles.emitting = true
	else:
		fail_purchase_sound.play()

@rpc("any_peer", "call_local", "reliable")
func upgrade_mvmt_spd():
	var players = network.get_children()
	for player in players:
		player.MAX_SPEED += 15
		player.footstep_speed += 0.1
	Global.ores[0] -= mvmt_spd_upgrade_price
	mvmt_spd_upgrade_price += mvmt_spd_price_increment
	costs[0].text = str(mvmt_spd_upgrade_price)

func _on_upg_blast_radius_pressed():
	if(Global.ores[0] >= blast_radius_upgrade_price):
		purchase_sound.play()
		purchase_particles.global_position = upg_blast_radius.global_position + OFFSET
		purchase_particles.restart()
		purchase_particles.emitting = true
	else:
		fail_purchase_sound.play()


func _on_upg_bullet_penetration_pressed():
	if(Global.ores[0] >= bullet_pierce_upgrade_price):
		rpc("upgrade_bullet_penetration")
		purchase_sound.play()
		purchase_particles.global_position = upg_bullet_penetration.global_position + OFFSET
		purchase_particles.restart()
		purchase_particles.emitting = true
	else:
		fail_purchase_sound.play()

@rpc("any_peer", "call_local", "reliable")
func upgrade_bullet_penetration():
	turret.bullet_pierce += 1 # Increases amount of targets pierced by 1
	Global.ores[0] -= bullet_pierce_upgrade_price
	bullet_pierce_upgrade_price += bullet_pierce_price_increment
	costs[0].text = str(bullet_pierce_upgrade_price)

func _on_upg_bullets_fired_pressed():
	if(Global.ores[0] >= bullets_fired_upgrade_price):
		rpc("upgrade_bullets_fired")
		purchase_sound.play()
		purchase_particles.global_position = upg_bullets_fired.global_position + OFFSET
		purchase_particles.restart()
		purchase_particles.emitting = true
	else:
		fail_purchase_sound.play()

@rpc("any_peer", "call_local", "reliable")
func upgrade_bullets_fired():
	turret.bullet_amount += 1 # Increases amount of targets pierced by 1
	Global.ores[0] -= bullets_fired_upgrade_price
	bullets_fired_upgrade_price += bullets_fired_price_increment
	costs[0].text = str(bullets_fired_upgrade_price)

func _on_upg_firerate_pressed():
	if(Global.ores[0] >= firerate_upgrade_price):
		rpc("upgrade_firerate")
		purchase_sound.play()
		purchase_particles.global_position = upg_firerate.global_position + OFFSET
		purchase_particles.restart()
		purchase_particles.emitting = true
	else:
		fail_purchase_sound.play()

@rpc("any_peer", "call_local", "reliable")
func upgrade_firerate():
	turret.base_turret_rate -= 0.05
	turret.shotgun_turret_rate -= 0.05
	turret.sniper_turret_rate -= 0.05
	turret.explosive_turret_rate -= 0.05
	Global.ores[0] -= firerate_upgrade_price
	firerate_upgrade_price += firerate_price_increment
	costs[0].text = str(firerate_upgrade_price)

func _on_upg_miner_spd_pressed():
	if(Global.ores[0] >= miner_spd_upgrade_price):
		purchase_sound.play()
		purchase_particles.global_position = upg_miner_spd.global_position + OFFSET
		purchase_particles.restart()
		purchase_particles.emitting = true
	else:
		fail_purchase_sound.play()
