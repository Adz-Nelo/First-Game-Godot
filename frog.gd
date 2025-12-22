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

func _on_player_death_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		death()

# ========== ONE FUNCTION HANDLES BOTH ==========
func _on_player_collision_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dead:
		# SIMPLE CHECK: Is player's bottom above frog's top?
		# The "-30" is a buffer zone - adjust based on your sprite sizes
		if body.position.y < self.position.y - 30:
			# Player is stomping from ABOVE - BOUNCE!
			print("STOMP! Player bounced on frog")
			
			# Get player and bounce them
			var player_node = get_node("../../Player/Player")
			if player_node:
				player_node.bounce_after_stomp()
			
			# Kill frog (no damage to player)
			death()
		else:
			# Player hit from SIDE/BELOW - take damage
			print("OUCH! Player hit frog from side")
			Game.playerHP -= 3
			death()
# ==============================================
		
func death():
	if is_dead:
		return
		
	is_dead = true
	Game.gold += 5
	Utilities.saveGame()
	chase = false
	$AnimatedSprite2D.play("Death")
	await $AnimatedSprite2D.animation_finished
	self.queue_free()
