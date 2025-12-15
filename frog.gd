extends CharacterBody2D

var speed = 50
var player
var chase = false

func _ready() -> void:
	get_node("AnimatedSprite2D").play("Idle")

func _physics_process(delta: float) -> void:
		# Gravity for frog
		velocity += get_gravity() * delta
		
		if chase == true:
			if get_node("AnimatedSprite2D").animation != "Death":
				get_node("AnimatedSprite2D").play("Jump")
			player = get_node("../../Player/Player")
			var direction = (player.position - self.position).normalized()
			
			if direction.x > 0:
				get_node("AnimatedSprite2D").flip_h = true
			else:
				get_node("AnimatedSprite2D").flip_h = false
			velocity.x = direction.x * speed
		else:
			if get_node("AnimatedSprite2D").animation != "Death":
				get_node("AnimatedSprite2D").play("Idle")
			velocity.x = 0
		move_and_slide()
		
func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false	

func _on_player_death_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		death() 

func _on_player_collision_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.health -= 3
		death()

func death():
	chase = false
	get_node("AnimatedSprite2D").play("Death")
	await get_node("AnimatedSprite2D").animation_finished
	self.queue_free()
