extends CharacterBody2D

var speed = 50
var player
var chase = false
var is_dead = false

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# Gravity for frog
	velocity += get_gravity() * delta
		
	if chase == true:
		if $AnimatedSprite2D.animation != "Death":
			$AnimatedSprite2D.play("Jump")
		player = get_node("../../Player/Player")
		var direction = (player.position - self.position).normalized()
			
		if direction.x > 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		velocity.x = direction.x * speed
	else:
		if $AnimatedSprite2D.animation != "Death":
			$AnimatedSprite2D.play("Idle")
		velocity.x = 0
	move_and_slide()
		
func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false

# Player stomps frog from top
func _on_player_death_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dead:
		AudioController.play_stomp_enemy()
		print("🎯 PlayerDeath area triggered (top stomp)")
		body.bounce_after_stomp()
		death()

# Player collides with frog from side/bottom
func _on_player_collision_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dead:
		print("💥 PlayerCollision triggered (side/bottom hit)")
		# CHANGED: Call player's take_damage function
		body.take_damage(3)
		death()
		
func death():
	if is_dead:	
		return 
		
	is_dead = true
	Game.gold += 1
	Utilities.saveGame()
	chase = false
	
	# Play death animation
	$AnimatedSprite2D.play("Death")
	
	# Wait for death animation
	await get_tree().create_timer(0.6).timeout
	
	# Disappear
	self.queue_free()
