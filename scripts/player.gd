extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -(2 * JUMP_HEIGHT) / JUMP_DURATION
const ACCELERATION = 800.0
const DECELERATION = 1000.0
const JUMP_HEIGHT = 70.0
const JUMP_DURATION = 0.3
const DOWN_GRAVITY = 2000.0  # Higher gravity when falling
const AIR_ACCELERATION = 600.0
#const COYOTE_TIME = 0.1  # Time after leaving the ground where a jump is still allowed
#const JUMP_BUFFER_TIME = 0.2  # Time a jump input is remembered before landing
#const TERMINAL_VELOCITY = 800.0  # Maximum fall speed


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D




func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	#flip
	if direction > 0:
		animated_sprite.flip_h = false
		
	elif direction < 0:
		animated_sprite.flip_h = true
		
	#animation play
	if direction == 0:
		animated_sprite.play("idle")
		
	else :
		animated_sprite.play("run")
		
	#Acc And Decc
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	

	move_and_slide()
	print(velocity)
