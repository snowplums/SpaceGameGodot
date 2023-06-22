extends Node

var enemies_left = 0
var current_planet = 1 #1 default
var planets_unlocked = 5 # 1 By default
var total_players

var smelted_copper = 0 #How much smelted copper the inventory has
var smelted_iron = 0 #How much smelted copper the inventory has
var smelted_platinum = 0 #How much smelted copper the inventory has
var smelted_gold = 0 #How much smelted copper the inventory has
var smelted_baitium = 0 #How much smelted copper the inventory has

var ore_in_radius = 0

var stop_mining = false #false dault

var hasShield = false #false default
var hasLockdown = false #false default

var ores = [smelted_copper, smelted_iron, smelted_platinum, smelted_gold, smelted_baitium]

func _process(_delta):
	smelted_copper =ores[0]
	smelted_iron = ores[1]
	smelted_platinum = ores[2]
	smelted_gold = ores[3]
	smelted_baitium = ores[4]
