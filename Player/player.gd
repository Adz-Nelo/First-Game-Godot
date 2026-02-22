extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -400.0

@onready var animation = get_node("AnimationPlayer")
@onready var animated_sprite = get_node("AnimatedSprite2D")

var jump_count = 0
var max_jumps = 2
var is_hurt = false
var is_dead = false

# Heartbeat variables simplified
var low_health_heartbeat = false
var heartbeat_cooldown = 0.0
var was_low_health = false

# Crouching
var is_crouching = false
var crouch_time = 0.0  # Track how long we've been crouching
var is_charged = false  # Is the jump charged?
var charge_expire_time = 0.0  # Timer for charge expiration

func _physics_process(delta: float) -> void:
	# If dead, skip everything
	if is_dead:
		velocity = Vector2.ZERO
		return
	
	# If hurt, skip controls but keep physics
	if is_hurt:
		velocity += get_gravity() * delta
		move_and_slide()
		return
	
	# Add the gravity - ALWAYS apply gravity!
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
	
	# Handle crouch input - HOLD to crouch
	if Input.is_action_pressed("ui_down") and is_on_floor():
		if not is_crouching:
			is_crouching = true
			crouch_time = 0.0
			is_charged = false
			print("⬇️ Crouching...")
		
		# Increase crouch time
		crouch_time += delta
		
		# Check if charged (1 second)
		if crouch_time >= 1.0 and not is_charged:
			is_charged = true
			charge_expire_time = 0.5 
			print("⚡ JUMP CHARGED!")
			AudioController.play_power_up()
			
			
			# Electric power-up effect!
			var tween = create_tween()
			tween.tween_property(animated_sprite, "modulate", Color(0.358, 1.145, 2.0, 1.0), 0.15)  # Bright blue flash
			tween.tween_property(animated_sprite, "modulate", Color(2.0, 2.0, 0.5), 0.15)  # Yellow electric
			tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1), 0.2)  # Fade to normal		
		
		animation.stop()
		animated_sprite.play("Crouch")
	else:
		if is_crouching and is_on_floor():  # Only stand up if on floor
			is_crouching = false
			crouch_time = 0.0
			print("⬆️ Stopped crouching")
			# Reset color if it was charged
			if is_charged:
				animated_sprite.modulate = Color.WHITE
				
	# Charge expiration countdown
	if is_charged and not is_crouching:
		charge_expire_time -= delta
		if charge_expire_time <= 0:
			is_charged = false
			animated_sprite.modulate = Color.WHITE
			print("⏱️ Charge expired!")

	# If crouching, stop horizontal movement but keep physics
	if is_crouching:
		velocity.x = 0
		move_and_slide()
		return
	
	# Handle jump - but NOT while crouching!
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps and not is_crouching:
		jump_count += 1
		var jump_power = JUMP_VELOCITY
		
		# CHARGED JUMP - much higher!
		if is_charged:
			jump_power = JUMP_VELOCITY * 1.5  # 50% more powerful!
			print("🚀 SUPER JUMP!")
			is_charged = false
			animated_sprite.modulate = Color.WHITE
			AudioController.play_super_jump()
			
			# SUPER JUMP SPLASH EFFECT!
			create_super_jump_splash()
			
		elif jump_count >= 1:
			jump_power = JUMP_VELOCITY * 0.85
			AudioController.play_jump()
			
		velocity.y = jump_power
		animation.play("Jump")
	
	# Movement code (only runs when NOT crouching)
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction == -1:
		animated_sprite.flip_h = true
	elif direction == 1:
		animated_sprite.flip_h = false
	
	if direction:
		velocity.x = direction * SPEED
		if velocity.y == 0:
			animation.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animation.play("Idle")
	
	if velocity.y > 0:
		animation.play("Fall")
	
	move_and_slide()

func bounce_after_stomp():
	print("🎯 PLAYER BOUNCED!")
	velocity.y = -300
	jump_count = 0

func take_damage(damage: int):
	if is_hurt or is_dead:
		return
	
	is_hurt = true
	
	# Play hurt animation
	animated_sprite.play("Hurt")
	AudioController.play_player_hurt()
	
	Game.playerHP -= damage
	print("💔 HP reduced to:", Game.playerHP)
	
	# Check if player died
	if Game.playerHP <= 0:
		player_die()
		return
	
	# Knockback
	if animated_sprite.flip_h:
		velocity.x = 200
	else:
		velocity.x = -200
	velocity.y = -150
	
	# Wait for hurt animation
	await get_tree().create_timer(0.5).timeout
	
	is_hurt = false
	
func create_super_jump_splash():
	# Create sparkling lightning particles
	for i in range(12):  # More particles for lightning effect
		var particle = Node2D.new()
		get_parent().add_child(particle)
		particle.global_position = global_position
		
		# Random direction for lightning burst
		var angle = randf_range(0, 2 * PI)
		var speed = randf_range(150, 300)
		var direction = Vector2(cos(angle), sin(angle))
		
		# Create visual (lightning spark)
		var visual = ColorRect.new()
		visual.size = Vector2(randf_range(6, 12), randf_range(6, 12))  # Random sizes
		visual.position = -visual.size / 2
		# Electric yellow/gold colors ⚡
		visual.color = Color(randf_range(1.0, 2.0), randf_range(0.8, 1.5), randf_range(0.0, 0.3))
		particle.add_child(visual)
		
		# Lightning sparkle animation
		var tween = create_tween()
		# Burst outward
		tween.tween_property(particle, "position", particle.position + direction * speed * 0.4, 0.4)
		# Flicker effect
		tween.parallel().tween_property(visual, "modulate:a", 0.0, 0.4)
		# Random rotation for extra sparkle
		tween.parallel().tween_property(visual, "rotation", randf_range(-PI, PI), 0.4)
		
		# Clean up
		tween.tween_callback(particle.queue_free)
	
	# Add a lightning flash on the player
	var flash_tween = create_tween()
	flash_tween.tween_property(animated_sprite, "modulate", Color(2.0, 2.0, 0.5), 0.1)  # Bright yellow
	flash_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.2)  # Back to normal

func _process(delta: float) -> void:
	# Handle low health heartbeat
	if Game.playerHP <= 1 and not low_health_heartbeat:
		start_heartbeat()
	elif Game.playerHP > 1 and low_health_heartbeat:
		stop_heartbeat()
	
	# Update heartbeat timer
	if low_health_heartbeat:
		heartbeat_cooldown -= delta
		if heartbeat_cooldown <= 0:
			AudioController.play_heart_beat()
			heartbeat_cooldown = 0.6  # 600ms between beats
			
			# Visual pulse
			animated_sprite.modulate = Color(1, 0.3, 0.3)
			var tween = create_tween()
			tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.3)

func start_heartbeat():
	low_health_heartbeat = true
	heartbeat_cooldown = 0.6
	print("💓 Low health - heartbeat started")

func stop_heartbeat():
	low_health_heartbeat = false
	print("💓 Health restored - heartbeat stopped")

func player_die():
	print("💀 Player died!")
	is_dead = true
	
	# CRITICAL: Stop _process() to prevent heartbeat from triggering
	set_process(false)
	
	# Stop all movement immediately
	velocity = Vector2.ZERO
	set_physics_process(false)  # Disable physics processing
	
	# Stop AnimationPlayer from overriding our death animation
	animation.stop()
	
	# Play death animation and sound
	animated_sprite.play("Death")
	AudioController.stop_heart_beat()
	AudioController.play_player_death()	
	
	# Create dramatic transition effect
	create_death_transition()
	
	# Wait for death animation to finish
	await get_tree().create_timer(1.5).timeout
	
	# Reset player HP back to max
	Game.playerHP = 3
	
	# Reset coins to level start
	if "level_start_coins" in Game:
		Game.gold = Game.level_start_coins
	
	# Go back to game over screen
	get_tree().change_scene_to_file("res://game_over.tscn")
	queue_free()

func create_death_transition():
	# Add screen shake effect
	add_screen_shake()
	
	# Slow down time for dramatic effect
	Engine.time_scale = 0.5
	await get_tree().create_timer(1.0).timeout
	Engine.time_scale = 1.0

func add_screen_shake():
	# Get the camera if you have one
	var camera = get_viewport().get_camera_2d()
	if camera:
		var shake_tween = create_tween()
		shake_tween.set_loops(8)
		shake_tween.tween_property(camera, "offset", Vector2(randf_range(-5, 5), randf_range(-5, 5)), 0.05)
		shake_tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
