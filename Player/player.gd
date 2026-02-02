extends CharacterBody2D
const SPEED = 300.0
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

func _physics_process(delta: float) -> void:
	# If dead, skip everything
	if is_dead:
		velocity = Vector2.ZERO  # Keep stopping velocity
		return
	
	# If hurt, skip controls but keep physics
	if is_hurt:
		velocity += get_gravity() * delta
		move_and_slide()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps:
		jump_count += 1
		
		var jump_power = JUMP_VELOCITY
		if jump_count > 1:
			jump_power = JUMP_VELOCITY * 0.85
		
		velocity.y = jump_power
		AudioController.play_jump()
		animation.play("Jump")
	
	# Movement code
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
