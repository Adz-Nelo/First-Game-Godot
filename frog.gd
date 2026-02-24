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

# Track previous velocity
var previous_velocity_y = 0.0

# Damage cooldown
var can_damage_player = true
var damage_cooldown = 1.0

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")
	hop_timer = randf_range(0.0, hop_cooldown)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Store velocity before move_and_slide
	previous_velocity_y = velocity.y
		
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
		
		# Disable PlayerCollision to prevent double trigger
		if has_node("PlayerCollision"):
			$PlayerCollision.set_deferred("monitoring", false)
		
		body.bounce_after_stomp()
		death()

# Player collides with frog from side/bottom OR frog lands on player
func _on_player_collision_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dead and can_damage_player:
		# Check if frog is ABOVE the player
		var frog_is_above = position.y < body.position.y - 20
		# Use PREVIOUS velocity (before it hit the ground)
		var frog_was_falling = previous_velocity_y > 50
		
		print("🔍 Collision! Frog Y:", position.y, " Player Y:", body.position.y)
		print("🔍 Frog above?", frog_is_above, " Was falling?", frog_was_falling, " prev velocity.y:", previous_velocity_y)
		
		if frog_is_above and frog_was_falling:
			# Frog landed on player from above
			print("🐸💥 Frog fell onto player's head!")
			body.take_damage(2)
			
			# MUCH stronger bounce
			velocity.y = -450
			
			# Better horizontal push calculation
			var horizontal_distance = position.x - body.position.x
			
			if abs(horizontal_distance) < 5:
				# Nearly centered - push based on player's facing direction
				if body.animated_sprite.flip_h:
					velocity.x = 200  # Player facing left, push right
				else:
					velocity.x = -200  # Player facing right, push left
			else:
				# Push away from player based on position
				velocity.x = sign(horizontal_distance) * 200
			
			# Start cooldown
			can_damage_player = false
			
			# Disable collision briefly so frog can escape
			$PlayerCollision.monitoring = false
			await get_tree().create_timer(0.3).timeout
			$PlayerCollision.monitoring = true
			
			await get_tree().create_timer(damage_cooldown).timeout
			can_damage_player = true
			
		else:
			# Normal side/bottom collision - player takes damage, frog dies
			print("💥 PlayerCollision triggered (side/bottom hit)")
			body.take_damage(1)
			death()

# FrogBody collision - handles stomps on main body
func _on_frog_body_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dead:
		# Check if player is coming from above (stomping)
		# Player's feet should be above frog's center, and player should be falling
		var player_is_above = body.global_position.y < global_position.y - 15
		var player_is_falling = body.velocity.y > 0
		
		print("🔍 FrogBody collision! Player Y:", body.global_position.y, " Frog Y:", global_position.y)
		print("🔍 Above?", player_is_above, " Falling?", player_is_falling)
		
		if player_is_above and player_is_falling:
			# Player is stomping on frog's body
			print("🎯 FrogBody stomp detected!")
			AudioController.play_stomp_enemy()
			
			# Disable PlayerCollision to prevent double damage
			if has_node("PlayerCollision"):
				$PlayerCollision.set_deferred("monitoring", false)
			
			body.bounce_after_stomp()
			death()
		else:
			# Player hit from side/bottom - player takes damage, frog dies
			print("💥 Side hit on frog body - player takes damage")
			body.take_damage(1)
			death()

func death():
	if is_dead:	
		return 
		
	is_dead = true
	Game.score += 50
	Utilities.saveGame()
	chase = false
	is_hopping = false
	velocity = Vector2.ZERO
	
	$AnimatedSprite2D.play("Death")
	await get_tree().create_timer(0.6).timeout
	self.queue_free()
