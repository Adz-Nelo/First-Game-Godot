extends CharacterBody2D

var speed = 50
var player
var chase = false
var is_dead = false

# Hopping variables
var is_hopping = false
var hop_timer = 0.0
var hop_cooldown = 1.5
var hop_force = -300
var hop_distance = 100

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")
	hop_timer = randf_range(0.0, hop_cooldown)
	
	# Connect FrogBody collision signal
	if has_node("FrogBody"):
		$FrogBody.body_entered.connect(_on_frog_body_body_entered)
		print("✅ FrogBody connected!")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# Gravity for frog
	velocity += get_gravity() * delta
	
	# Hop timer countdown
	if is_on_floor() and not is_hopping:
		hop_timer -= delta
		
		if hop_timer <= 0:
			hop()
			hop_timer = hop_cooldown
	
	if chase == true:
		player = get_node("../../Player/Player")
		var direction = (player.position - self.position).normalized()
		
		if direction.x > 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		
		if is_hopping:
			velocity.x = direction.x * speed * 2
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	else:
		if is_hopping:
			if $AnimatedSprite2D.flip_h:
				velocity.x = speed
			else:
				velocity.x = -speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	# Update animation based on state
	if is_dead:
		return
	elif is_on_floor():
		if velocity.x != 0:
			$AnimatedSprite2D.play("Jump")
		else:
			$AnimatedSprite2D.play("Idle")
	else:
		$AnimatedSprite2D.play("Jump")
	
	move_and_slide()
	
	# Check if landed
	if is_hopping and is_on_floor() and velocity.y >= 0:
		is_hopping = false

func hop():
	if not is_on_floor() or is_dead:
		return
	
	is_hopping = true
	velocity.y = hop_force
	
	if not chase:
		if randf() > 0.5:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	
	$AnimatedSprite2D.play("Jump")

# NEW: When FrogBody (bottom of frog) touches player
func _on_frog_body_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dead:
		print("🐸 FrogBody touched player! Velocity.y:", velocity.y)
		# Only damage if frog is falling down
		if velocity.y > 50:  # Falling downward
			print("🐸💥 Frog landed on player's head!")
			body.take_damage(2)
			# Bounce frog back up slightly
			velocity.y = -150

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true
		hop_cooldown = 0.8

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false
		hop_cooldown = 1.5

# Player stomps frog from top (kills frog)
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
		body.take_damage(3)
		death()

func death():
	if is_dead:	
		return 
		
	is_dead = true
	Game.gold += 1
	Utilities.saveGame()
	chase = false
	is_hopping = false
	velocity = Vector2.ZERO
	
	$AnimatedSprite2D.play("Death")
	await get_tree().create_timer(0.6).timeout
	self.queue_free()
