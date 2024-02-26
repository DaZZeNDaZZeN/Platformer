extends CharacterBody2D

@onready var Camera = $Camera2D
@onready var Dash_effect = $DashEffect2D

# Movement variables and constants
const ACCELERATION = 200
const FRICTION = 100
const MAX_SPEED = 550.0
var direction = "right"

# Jump variables and constants
const JUMP_VELOCITY = -690.0
const WALL_JUMP_PUSH = 550
var max_jumps = 1
var jump_count = 0

# Gravity variables and constants
const GRAVITY_ACCELERATION = 1600
const GRAVITY_MAX_SPEED = 3000

# Dash variables and constants
const DASH_SPEED = 1000
const DASH_TIME = 0.33
var dash_timer = 1

# Miscellaneous variables and constants
const KOYOTE_TIME = 0.016 * 5
var Velocity = Vector2.ZERO
var koyote_timer = 0

func _ready():
	Dash_effect.lifetime = DASH_TIME

func _physics_process(delta):
	move_and_slide()
	
func _process(delta):
	
	# Adding koyote time
	if not is_on_floor():
		koyote_timer += delta
	else:
		koyote_timer = 0
		# Reset gravity and jump count
		Velocity.y = 0
		jump_count = 0
	
	if koyote_timer > KOYOTE_TIME: # 5 frames if 60 fps
		
		# Remove 1 jump if falling
		if jump_count == 0:
			jump_count = 1
		
		# Add the gravity.
		Velocity.y += GRAVITY_ACCELERATION * delta
		if Velocity.y > GRAVITY_MAX_SPEED:
			Velocity.y = GRAVITY_MAX_SPEED
		
		# If bumped into ceiling reset velocity
		if is_on_ceiling():
			Velocity.y = GRAVITY_ACCELERATION / 10
	else: # if on floor with koyote time
		pass
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if jump_count < max_jumps:
			Velocity.y = JUMP_VELOCITY
			jump_count += 1
		elif is_on_wall():
			Velocity.y = JUMP_VELOCITY
			Velocity.x = WALL_JUMP_PUSH * get_last_slide_collision().get_normal().x
			jump_count = 1
	
	
	
	# Left and right movement
	if Input.is_action_pressed("left"):
		Velocity.x -= ACCELERATION
		direction = "left"
	elif Input.is_action_pressed("right"):
		Velocity.x += ACCELERATION
		direction = "right"
	
	# Apply stopping friction
	if Velocity.x > FRICTION:
		Velocity.x -= FRICTION
	elif Velocity.x < -FRICTION:
		Velocity.x += FRICTION
	else: Velocity.x = 0
	
	# Cap the speed
	if Velocity.x > MAX_SPEED:
		Velocity.x = MAX_SPEED
	elif Velocity.x < -MAX_SPEED:
		Velocity.x = -MAX_SPEED
	
	# Handle dash
	if Input.is_action_just_pressed("dash"):
		Dash_effect.emitting = true # emit particles
		dash_timer = 0 # reset dash_time
	if dash_timer < DASH_TIME: # doing dash
		dash_timer += delta
		if direction == "right": # x component
			Velocity.x = DASH_SPEED
		else:
			Velocity.x = -DASH_SPEED
		Velocity.y = 0 # y component
	
	# Pass the velocity into class functions
	velocity = Velocity
	
