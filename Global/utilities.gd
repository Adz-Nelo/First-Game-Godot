extends Node

const save_path = "res://savegame.bin"

func saveGame():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var data: Dictionary = {
		"playerHP": Game.playerHP,
		"gold": Game.gold,
		"score": Game.score   
	}
	
	var json_str = JSON.stringify(data)
	file.store_line(json_str)
	
func loadGame():
	var file = FileAccess.open(save_path, FileAccess.READ) 
	if FileAccess.file_exists(save_path) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				Game.playerHP = current_line["playerHP"]
				Game.gold = current_line["gold"]
				Game.score = current_line["score"]
