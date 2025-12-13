extends CharacterBody2D

func _physics_process(delta: float) -> void:
		velocity += get_gravity() * delta
		move_and_slide()
		
func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("player")
