extends CharacterBody2D

# Movement Constants
const SPEED = 300.0
const ACCELERATION = 800.0
const DECELERATION = 1000.0
const AIR_ACCELERATION = 600.0

# Jumping Constants
const JUMP_HEIGHT = 70.0
const JUMP_DURATION = 0.3
const JUMP_VELOCITY = -(2 * JUMP_HEIGHT) / JUMP_DURATION
const DOWN_GRAVITY = 2000.0
const UP_GRAVITY = 1500.0  # Lower gravity when going up
const MAX_JUMPS = 2  # Double Jump Support

# Camera Settings
const CAMERA_DAMPING = 5.0
const LOOKAHEAD_DISTANCE = Vector2(100, 50)
const ZOOM_NORMAL = Vector2(1.0, 1.0)
const ZOOM_RUNNING = Vector2(1.2, 1.2)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

var jumps_left = MAX_JUMPS  # Tracks available jumps
var is_jumping = false

func _ready() -> void:
	# Configure Camera2D
	camera.offset = Vector2.ZERO
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = CAMERA_DAMPING
	camera.zoom = ZOOM_NORMAL
	camera.drag_margin_h_enabled = false  # Disable horizontal drag margins
	camera.drag_margin_v_enabled = false  # Disable vertical drag margins
	camera.ignore_rotation = true  # Ignore player rotation
	camera.ignore_jumps = true  # Ignore jumps when following player
	camera.zoom = ZOOM_NORMAL

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += (DOWN_GRAVITY if velocity.y > 0 else UP_GRAVITY) * delta
	else:
		jumps_left = MAX_JUMPS  # Reset jumps on landing

	# Jump Logic
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
		is_jumping = true

	# Jump Cutoff (Variable Height)
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= 0.5  # Cut jump height

	# Get movement direction
	var direction := Input.get_axis("ui_left", "ui_right")

	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Play animation
	if direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")

	# Acceleration & Deceleration
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, (AIR_ACCELERATION if not is_on_floor() else ACCELERATION) * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	# Update Camera Zoom
	camera.zoom = ZOOM_RUNNING if direction != 0 else ZOOM_NORMAL

	move_and_slide()
