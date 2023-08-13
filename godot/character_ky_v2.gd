extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var ANIM

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# State Machine time mfer
var state = "idle"

func _ready():
	ANIM = get_node("AnimatedSprite2D")
	

func calc_input():
	# Handles what input is being pressed. Returns an array where:
	# 0 - left, 1 - right, 2 - up, 3 - down
	var left = Input.is_action_pressed("gamepad_left")
	var right = Input.is_action_pressed("gamepad_right")
	var up = Input.is_action_pressed("gamepad_right")
	var down = Input.is_action_pressed("gamepad_down")
	
	return [left and not right, right and not left, up and not down, down and not up]

func start_anim(anim_name, inbetween):
	# TODO - Unable to leave crouch once it begins.
	# Handles starting an animation with or without inbetween frames.
	if inbetween:
		# Assumes the inbetween frames of animation X are called start_X.
		ANIM.set_animation("start_" + anim_name)
		print("ANIME: Waiting for end of start_" + anim_name)
		await ANIM.animation_looped or ANIM.animation_changed
		print("ANIME: End of start_" + anim_name)
		if ANIM.get_animation() != "start_" + anim_name:
			return
	ANIM.set_animation(anim_name)
	return

func _physics_process(delta):
	var current_input = calc_input()
	
	# TODO - Implement jumping with anim ya lazy shit
	
	determine_state(current_input, delta)
	
	act_state()
	
	# Handle animation
	var anim_name = ANIM.get_animation()
	if anim_name != state and anim_name != ("start_" + state):
		print("STATE: Changed from " + anim_name + " to " + state)
		var has_start_anim = state in ["crouch"]
		start_anim(state, has_start_anim)

	move_and_slide()

func determine_state(current_input, delta):
	# TODO - Remove Delta from this function!
	# Let's check state.
	match state:
		"idle":
			# On the floor, not doing anything.
			# Handle basic movement.
			if current_input[3]:
				state="crouch"
			elif current_input[1]:
				state = "walk backward"
			elif current_input[0]:
				state = "walk forward"
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			# Add the gravity.
			if not is_on_floor():
				velocity.y += gravity * delta

			# Handle Jump.
			if Input.is_action_just_pressed("gamepad_up") and is_on_floor():
				velocity.y = JUMP_VELOCITY
		
		"crouch":
			if not current_input[3]:
				state="idle"
		
		"walk forward":
			if not current_input[0]:
				state="idle"
		
		"walk backward":
			if not current_input[1]:
				state="idle"
		

func act_state():
	match state:
		"walk forward":
			velocity.x = -SPEED
		
		"walk backward":
			velocity.x = SPEED
