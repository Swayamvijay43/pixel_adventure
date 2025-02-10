extends CharacterBody2D

# Movement constants
const SPEED = 300.0
const ACCELERATION = 800.0
const DECELERATION = 1000.0
const AIR_ACCELERATION = 600.0  # Less control in air
const TURN_SPEED = 1200.0  # Controls how fast the player turns around
const MAX_SPEED = 500.0  # Upper speed limit
const INSTANT_MOVE = true  # If true, instantly sets movement direction

# Jump physics
const JUMP_HEIGHT = 70.0
const DOWN_GRAVITY = 1500.0  # Adjusted for better jump arc
const JUMP_VELOCITY = -sqrt(2 * DOWN_GRAVITY * JUMP_HEIGHT)  # Physics-based jump strength
const JUMP_CUTOFF = 0.75  # Controls variable jump height

# Double Jump
const MAX_JUMPS = 2
const DOUBLE_JUMP_VELOCITY = JUMP_VELOCITY * 0.9  # Slightly weaker second jump

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var run_effect = $RunEffect
@onready var jump_effect = $JumpEffect
@onready var land_effect = $LandEffect

var jumps_left = MAX_JUMPS  # Tracks available jumps
var was_in_air = false

func _ready():
	# Ensure particle effects are set up properly
	jump_effect.one_shot = true
	land_effect.one_shot = true
	run_effect.one_shot = false  # Running effect should be continuous

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += DOWN_GRAVITY * delta
	else:
		if was_in_air:
			land_effect.restart()  # Play landing effect when touching ground
			land_effect.emitting = true
		jumps_left = MAX_JUMPS  # Reset jumps on landing

	was_in_air = not is_on_floor()

	# Jump logic
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		jump_effect.restart()  # Ensure jump effect restarts
		jump_effect.emitting = true
		
		if jumps_left == MAX_JUMPS:
			velocity.y = JUMP_VELOCITY  # Normal jump
		else:
			velocity.y = DOUBLE_JUMP_VELOCITY  # Weaker double jump
		
		jumps_left -= 1

	# Jump Cutoff (Variable Jump Height)
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= JUMP_CUTOFF

	# Get movement input
	var direction := Input.get_axis("ui_left", "ui_right")

	# Flip sprite based on direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Animation handling
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
			run_effect.emitting = false  # Stop running effect
		else:
			animated_sprite.play("run")
			run_effect.emitting = true   # Play running effect
	else:
		animated_sprite.play("jump")  # Use "fall" if falling

	# Movement Logic
	if INSTANT_MOVE:
		velocity.x = direction * SPEED  # Instantly set speed
	else:
		if direction != 0:
			if is_on_floor():
				if (velocity.x > 0 and direction < 0) or (velocity.x < 0 and direction > 0):
					velocity.x = move_toward(velocity.x, direction * SPEED, TURN_SPEED * delta)
				else:
					velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
			else:
				velocity.x = move_toward(velocity.x, direction * SPEED, AIR_ACCELERATION * delta)
		else:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, AIR_ACCELERATION * delta)

	# Apply max speed limit
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

	move_and_slide()
