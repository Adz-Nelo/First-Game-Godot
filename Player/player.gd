extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animation = get_node("AnimationPlayer")
@onready var animated_sprite = get_node("AnimatedSprite2D")

var jump_count = 0
var max_jumps = 2
var is_hurt = false

func _physics_process(delta: float) -> void:
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
	
	if Game.playerHP <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://main.tscn")

func bounce_after_stomp():
	print("🎯 PLAYER BOUNCED!")
	velocity.y = -300
	jump_count = 0

func take_damage(damage: int):
	if is_hurt:
		return
	
	is_hurt = true
	
	# FIXED: Use AnimatedSprite2D instead of AnimationPlayer
	animated_sprite.play("Hurt")
	
	AudioController.play_player_hurt()
	
	Game.playerHP -= damage
	print("💔 HP reduced to:", Game.playerHP)
	
	# Knockback
	if animated_sprite.flip_h:
		velocity.x = 200
	else:
		velocity.x = -200
	velocity.y = -150
	
	# Wait for hurt animation
	await get_tree().create_timer(0.5).timeout
	
	is_hurt = false
	
	if Game.playerHP <= 0:
		print("💀 Player died!")
		queue_free()
		get_tree().change_scene_to_file("res://main.tscn")
