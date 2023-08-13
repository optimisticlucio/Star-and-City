extends CharacterBody2D

# The character's speed.
const SPEED = 300.0
# The character's jumping velocity.
const JUMP_VELOCITY = -700.0

# Animations which need to be transitioned into.
const START_ANIMS = ["crouch", "jumping"]
# The animation.
var ANIM

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# The states.
enum State {IDLE, CROUCH, WALK_FORWARD, WALK_BACKWARD, JUMPING}

# Get the animation name of the State.
func state_name(state: State) -> String:
	match state:
		State.IDLE:
			return "idle"
		State.CROUCH:
			return "crouch"
		State.WALK_FORWARD:
			return "walk forward"
		State.WALK_BACKWARD:
			return "walk backward"
		State.JUMPING:
			return "jumping"
			
	return "UNKNOWN_ANIMATION" # Necessary because the compiler is a bit stupid.

# State Machine time mfer
var state = State.IDLE

func _ready():
	ANIM = get_node("AnimatedSprite2D")

# Handles what input is being pressed. Returns an array where:
# 0: left, 1: right, 2: up, 3: down
func calc_input() -> Array[bool]:
	var left = Input.is_action_pressed("gamepad_left")
	var right = Input.is_action_pressed("gamepad_right")
	var up = Input.is_action_pressed("gamepad_up")
	var down = Input.is_action_pressed("gamepad_down")
	
	return [left and not right, right and not left, up and not down, down and not up]

# Handles starting an animation with or without inbetween frames.
func start_anim(anim_name: String, in_between: bool):
	if in_between:
		# Assumes the inbetween frames of animation X are called start_X.
		var anim_start_name = "start_" + anim_name
		ANIM.set_animation(anim_start_name)
		print("ANIM: Waiting for end of " + anim_start_name)
		await ANIM.animation_looped or ANIM.animation_changed
		print("ANIM: End of " + anim_start_name)
		if ANIM.get_animation() != anim_start_name:
			return
	ANIM.set_animation(anim_name)
	return

func _physics_process(delta):
	var current_input = calc_input()
	
	# Determine the state.
	determine_state(current_input, delta)
	
	# Set the action depending on the state.
	act_state(state)
	
	# Handle animation
	var anim_name = ANIM.get_animation()
	var next_anim_name = state_name(state)
	if anim_name != next_anim_name and anim_name != ("start_" + next_anim_name):
		print("STATE: Changed from " + anim_name + " to " + next_anim_name)
		start_anim(next_anim_name, next_anim_name in START_ANIMS)

	# NOTE: what is this
	move_and_slide()

# Determine what the current state of the player is based on the input.
# The transitions of the state machine occur here.
func determine_state(current_input: Array[bool], delta):
	# TODO - Remove Delta from this function!

	# Check the current state to see which
	# state transitions are possible.
	match state:
		State.IDLE:
			if current_input[3]:
				state = State.CROUCH
			elif current_input[1]:
				state = State.WALK_BACKWARD
			elif current_input[0]:
				state = State.WALK_FORWARD
			# Only allow jumping if the player is on the floor.
			elif current_input[2] and is_on_floor():
				state = State.JUMPING
				velocity.y = JUMP_VELOCITY
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			# If the player is not on the floor,
			# give them gravity.
			if not is_on_floor():
				velocity.y += gravity * delta
		
		State.CROUCH:
			if not current_input[3]:
				state = State.IDLE
		
		State.WALK_FORWARD:
			if not current_input[0]:
				state = State.IDLE
		
		State.WALK_BACKWARD:
			if not current_input[1]:
				state = State.IDLE
				
		State.JUMPING:
			# Add the gravity.
			if not is_on_floor():
				velocity.y += gravity * delta
			else:
				state = State.IDLE
		

# Change movement depending on the state.
func act_state(state: State):
	match state:
		State.WALK_FORWARD:
			velocity.x = -SPEED
		
		State.WALK_BACKWARD:
			velocity.x = SPEED
			
		State.IDLE:
			velocity.x = 0;
