extends CharacterBody2D

# Movement constants
const SPEED = 300.0
const ACCELERATION = 1600.0  # Increased for noticeable effect
const DECELERATION = 1800.0  # Stronger to stop quickly
const AIR_ACCELERATION = 1000.0  # Less control in air
const TURN_SPEED = 2000.0  # Faster turning
const MAX_SPEED = 10000.0  # Upper speed limit
const INSTANT_MOVE = false  # Disable for acceleration to work

# Jump physics
const JUMP_HEIGHT = 70.0
const DOWN_GRAVITY = 1500.0
const JUMP_VELOCITY = -sqrt(2 * DOWN_GRAVITY * JUMP_HEIGHT)
const JUMP_CUTOFF = 0.75

# Double Jump
const MAX_JUMPS = 2
const DOUBLE_JUMP_VELOCITY = JUMP_VELOCITY * 0.9

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var run_effect = $RunEffect
@onready var jump_effect = $JumpEffect
@onready var land_effect = $LandEffect

var jumps_left = MAX_JUMPS
var was_in_air = false

func _ready():
	jump_effect.one_shot = true
	land_effect.one_shot = true
	run_effect.one_shot = false

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += DOWN_GRAVITY * delta
	else:
		if was_in_air:
			land_effect.restart()
			land_effect.emitting = true
		jumps_left = MAX_JUMPS  # Reset jumps on landing

	was_in_air = not is_on_floor()

	# Handle Jumping
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		jump_effect.restart()
		jump_effect.emitting = true
		
		if jumps_left == MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
		else:
			velocity.y = DOUBLE_JUMP_VELOCITY
		
		jumps_left -= 1

	# Variable Jump Height
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= JUMP_CUTOFF

	# Get movement input
	var direction := Input.get_axis("ui_left", "ui_right")

	# Flip sprite based on movement direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Handle animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
			run_effect.emitting = false
		else:
			animated_sprite.play("run")
			run_effect.emitting = true
	else:
		animated_sprite.play("jump")

	# Movement with Acceleration and Deceleration
	if direction != 0:
		if is_on_floor():
			if (velocity.x > 0 and direction < 0) or (velocity.x < 0 and direction > 0):
				velocity.x = move_toward(velocity.x, direction * MAX_SPEED, TURN_SPEED * delta)
			else:
				velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * MAX_SPEED, AIR_ACCELERATION * delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_ACCELERATION * delta)

	# Apply max speed limit
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

	# Debugging
	print("Direction:", direction, " | Velocity X:", velocity.x)

	move_and_slide()
	print(velocity.x)
