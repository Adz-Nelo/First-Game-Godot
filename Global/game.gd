extends Node

var playerHP = 3
var gold = 0
var level_start_coins = 0
var score = 0
var level_start_score = 0

func _ready():
	# Save how many coins we had when entering this level
	Game.level_start_coins = Game.gold
	Game.level_start_score = Game.score
