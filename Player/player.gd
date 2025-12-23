extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animation = get_node("AnimationPlayer")
@onready var animated_sprite = get_node("AnimatedSprite2D")

# ========== BOUNCE FUNCTION ==========
func bounce_after_stomp():
	print("🎯 PLAYER BOUNCED!")
	velocity.y = -300  # Strong bounce force
	# Optional: Play bounce sound
	# AudioController.play("stomp")
# ======================================

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		AudioController.play_jump()
		velocity.y = JUMP_VELOCITY
		animation.play("Jump")

	# Get the input direction and handle the movement/deceleration.
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
	
	# DEBUG: Test bounce with a key press
	if Input.is_action_just_pressed("ui_select"):
		bounce_after_stomp()
		print("Manual bounce test. Velocity: ", velocity)
	
	if Game.playerHP <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://main.tscn")
