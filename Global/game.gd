extends Node

# Total Items collected
var total_coins_in_level = 0
var total_cherries_in_level = 0
var total_gems_in_level = 0

# Reset/Default style
var playerHP = 3
var gold = 0
var level_start_coin = 0
var score = 0
var level_start_score = 0
var cherry = 0
var level_start_cherry = 0
var gem = 0
var level_start_gem = 0
var checkpoint_position = Vector2.ZERO

func _ready():
	# Save how many coins we had when entering this level
	Game.level_start_coin = Game.gold
	Game.level_start_score = Game.score
	Game.level_start_cherry = Game.cherry
	Game.level_start_gem = Game.gem
