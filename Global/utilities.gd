extends Node

const save_path = "res://savegame.bin"

func saveGame():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var data: Dictionary = {
		"PlayerHP": Game.playerHP,
		"Gold": Game.gold, 
	}
	
	var json_str = JSON.stringify(data)
	file.store_line(json_str)
	
func loadGame():
	var file = FileAccess.open(save_path, FileAccess.READ)
	
	if FileAccess.file_exists(save_path) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				Game.playerHP = current_line["PlayerHP"]
				Game.gold = current_line["Gold"]
