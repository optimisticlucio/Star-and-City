extends CharacterBody2D

# The character's speed.
const SPEED = 300.0
# The character's jumping velocity.
const JUMP_VELOCITY = -400.0
# The input buffer's size
const BUFFER_LENGTH = 128

# The animation.
var ANIM: AnimationPlayer

# The current state.
var state = State.IDLE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Counts the amount of remaining air movement actions left to the player, such as airdashing.
var init_air_act: int = 1 # the initialization value
var air_act_count: int = init_air_act

# Counts down, once a frame, if we want to have a state that the player can't change from.
var lock_frames = 0

# Enum representing directions. -1 means right, 1 means left.
enum Direction {RIGHT = -1, LEFT = 1}

# Direction the player is currently facing.
var direction: Direction = Direction.RIGHT

# The input buffer, to handle inputs.
var buffer = InputBuffer.new()

# Summoning a character
func _init():
	pass #TODO. 
	# MAKE THIS FUNCTION TAKE LOCATION, SPRITEMAP, AND INPUTS

# Class representing the virtual buttons a player pressed at a specific frame, and
# for how long they have been pressing them.
# Initially assumes the player did not, in fact, press them.
class VirtualInput:
	var LEFT = 0
	var RIGHT = 0
	var UP = 0
	var DOWN = 0
	var A = 0
	var B = 0
	var C = 0

# Circular buffer that holds and reads the inputs pressed in the past 64 frames. 
# TODO - For SOME reason, breaks inputs at random?
# When holding down, input breaks on index values 1, 5, 10, 21, and 32. Don't ask me why.
class InputBuffer:
	var index: int = 0 
	var past_inputs: Array[VirtualInput] = []
	
	func _init():
		# To create an empty, 64 input buffer.d
		past_inputs.resize(BUFFER_LENGTH)
		past_inputs.fill(VirtualInput.new())
	
	# Set a new input into the buffer.
	func set_new_input(new_input: VirtualInput) -> void:
		past_inputs[index] = new_input
		index = (index + 1) % BUFFER_LENGTH
	
	# Get the latest input.
	func get_last_input() -> VirtualInput:
		return past_inputs[(index - 1) % BUFFER_LENGTH]
	
	# Reads if a player did an action, given a certain leniency. 
	# Actions are written in numpad notation.
	#
	# NOTES - From personal testing, here's the ranges leniency should be
	# kept to: 1 if you want all the buttons pressed at once. 8 if you want
	# a bit of a strict timing. 24 if you want it to be possible basically
	# while half asleep. 12 for a decently fast timing. 16 seems to be the
	# sweet spot for convenience.
	func read_action(action: String, leniency: int) -> bool:
		var action_index = action.length() - 1 # The length of the action string.
		var buffer_index = index - 1 # The current index of the buffer.
		var endpoint = (index + 1) % BUFFER_LENGTH # To not do this calculation every loop
		var current_leniency = leniency # The leniency. Reassigned as the value is modified.
		
		# Do this for every char in the string, without looping the buffer.
		while action_index >= 0:
			# If we looped the buffer, that's bad.
			if buffer_index == endpoint:
				return false
			
			# First, let's see what input we are reading for this time, and insert the
			# appropriate lambda function into this convenient variable.
			var lambda_func
			match action[action_index]:
				"6":
					lambda_func = func(index): 
						return (past_inputs[index].RIGHT > 0 and past_inputs[index].UP == 0 and past_inputs[index].DOWN == 0)
				"7":
					lambda_func = func(index): 
						return (past_inputs[index].LEFT > 0 and past_inputs[index].UP > 0)
				"8":
					lambda_func = func(index): 
						return (past_inputs[index].UP > 0 and past_inputs[index].LEFT == 0 and past_inputs[index].RIGHT == 0)
				"9":
					lambda_func = func(index): 
						return (past_inputs[index].RIGHT > 0 and past_inputs[index].UP > 0)
				"5":
					lambda_func = func(index): 
						return (past_inputs[index].RIGHT == 0 and past_inputs[index].UP == 0 and past_inputs[index].LEFT == 0 and past_inputs[index].DOWN == 0)
				"4":
					lambda_func = func(index): 
						return (past_inputs[index].LEFT > 0 and past_inputs[index].UP == 0 and past_inputs[index].DOWN == 0)
				"1":
					lambda_func = func(index): 
						return (past_inputs[index].LEFT > 0 and past_inputs[index].DOWN > 0)
				"2":
					lambda_func = func(index): 
						return (past_inputs[index].DOWN > 0 and past_inputs[index].LEFT == 0 and past_inputs[index].RIGHT == 0)
				"3":
					lambda_func = func(index): 
						return (past_inputs[index].RIGHT > 0 and past_inputs[index].DOWN > 0)
				"A":
					lambda_func = func(index): 
						return (past_inputs[index].A > 0)
				"B":
					lambda_func = func(index): 
						return (past_inputs[index].B > 0)
				"C":
					lambda_func = func(index): 
						return (past_inputs[index].C > 0)
				_:
					print("READ_ACTION: Undefined action found - " + action[action_index])
					return false
			
			# If not found, kill the loop.
			while current_leniency > 0:
				if lambda_func.call(buffer_index):
					break
				current_leniency -= 1
				buffer_index = (buffer_index - 1) % BUFFER_LENGTH
					
			if current_leniency == 0:
				return false
			
			action_index -= 1
		
		# If loop was finished and we didn't loop the buffer, return true.
		return true
	
	# Checks if a button was pressed the frame before. Written in numpad notation.
	func just_pressed(char: String) -> bool:
		var last_in = get_last_input()
		match char:
			"2":
				return (last_in.DOWN == 1)
			"4":
				return (last_in.LEFT == 1)
			"6":
				return (last_in.RIGHT == 1)
			"8":
				return (last_in.UP == 1)
			"A":
				return (last_in.A == 1)
			"B":
				return (last_in.B == 1)
			"C":
				return (last_in.C == 1)
			_: 
				print("JUST_PRESSED: Undefined action found - " + char)
				return false
		return false
		

# The states.
enum State {IDLE, CROUCH, WALK_FORWARD, WALK_BACKWARD, JUMPING, INIT_JUMPING, CLOSE_SLASH, CROUCH_SLASH}

# Get the animation name of the State.
func state_name(input_state: State) -> String:
	match input_state:
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
		State.INIT_JUMPING:
			return "jumping"
		State.CLOSE_SLASH:
			return "closeslash"
		State.CROUCH_SLASH:
			return "crouchslash"
			
	return "UNKNOWN_ANIMATION" # Necessary because the compiler is a bit stupid.

func _ready():
	ANIM = get_node("AnimationPlayer")
	
	# NOTE - I am right now testing flipping a player for side switching.
	# REMOVE THIS ONCE DONE!
	self.scale = Vector2(direction, 1)

# Reads the currently pressed input, and puts it into the input buffer.
func calc_input() -> void:
	# First let's get what was last pressed, to work with it.
	var last_input = buffer.get_last_input()
	
	# Now we get what was pressed
	var left
	var right
	var up = Input.is_action_pressed("gamepad_up")
	var down = Input.is_action_pressed("gamepad_down")
	var A = Input.is_action_pressed("gamepad_A")
	var B = Input.is_action_pressed("gamepad_B")
	var C = Input.is_action_pressed("gamepad_C")
	
	if direction == Direction.RIGHT:
		left = Input.is_action_pressed("gamepad_left")
		right = Input.is_action_pressed("gamepad_right")
	else:
		right = Input.is_action_pressed("gamepad_left")
		left = Input.is_action_pressed("gamepad_right")
	
	# Now, let's see what we incremate and what we keep in place.
	# TODO - there has got to be a cleaner implementation of BOTH of these sections.
	var new_input = VirtualInput.new()
	if left and not right:
		new_input.LEFT = last_input.LEFT + 1
	if right and not left:
		new_input.RIGHT = last_input.RIGHT + 1
	if up and not down:
		new_input.UP = last_input.UP + 1
	if down and not up:
		new_input.DOWN = last_input.DOWN + 1
	if A:
		new_input.A = last_input.A + 1
	if B:
		new_input.B = last_input.B + 1
	if C:
		new_input.C = last_input.C + 1
		
	
	# Now that we have our new input, let's insert it appropriately.
	buffer.set_new_input(new_input)

# Handles starting an animation with or without inbetween frames.
func start_anim(anim_name: String):
	if ANIM.has_animation("start_" + anim_name):
		ANIM.play("start_" + anim_name)
		ANIM.queue(anim_name)
	else:
		ANIM.play(anim_name)

func _physics_process(delta):
	calc_input()
	
	# Check if lock frames are active.
	if (lock_frames == 0):
		# Determine the state.
		determine_state()
	
		# Set the action depending on the state.
		act_state(delta)
	else:
		lock_frames -= 1
	
	# Handle animation
	var anim_name = ANIM.current_animation
	var next_anim_name = state_name(state)
	if anim_name != next_anim_name and anim_name != ("start_" + next_anim_name):
		print("STATE: Changed from " + anim_name + " to " + next_anim_name)
		start_anim(next_anim_name)

	move_and_slide()

# Determine what the current state of the player is based on the input.
# The transitions of the state machine occur here.
func determine_state():
	
	# Check the current state to see which state transitions are possible.
	match state:
		State.IDLE:
			if buffer.read_action("A", 1): 
				# Attacks take precedent!
				state = State.CLOSE_SLASH
			elif buffer.read_action("2", 1):
				state = State.CROUCH
			elif buffer.read_action("4", 1):
				state = State.WALK_BACKWARD
			elif buffer.read_action("6", 1):
				state = State.WALK_FORWARD
			elif buffer.read_action("8", 1):
				state = State.INIT_JUMPING
		
		State.CLOSE_SLASH:
			# Only runs after the player is immobilized for a few frames
			state = State.IDLE
		
		State.CROUCH: # Crouch takes precedent over other states!
			# Only exception is jumping or hitstun.
			if not buffer.read_action("2", 1):
				state = State.IDLE
			elif buffer.read_action("A", 1):
				state = State.CROUCH_SLASH
		
		State.WALK_FORWARD:
			if buffer.read_action("2", 1):
				state = State.CROUCH
			elif buffer.read_action("8", 1):
				state = State.INIT_JUMPING
			elif buffer.read_action("A", 1):
				state = State.CLOSE_SLASH
			elif not buffer.read_action("6", 1):
				state = State.IDLE
		
		State.WALK_BACKWARD:
			if buffer.read_action("2", 1):
				state = State.CROUCH
			elif buffer.read_action("8", 1):
				state = State.INIT_JUMPING
			elif buffer.read_action("A", 1):
				state = State.CLOSE_SLASH
			elif not buffer.read_action("4", 1):
				state = State.IDLE
				
		
		State.INIT_JUMPING:
			state = State.JUMPING
		
		State.JUMPING:
			# Handle landing
			if is_on_floor():
				air_act_count = init_air_act # NOTE - Maybe should be in act? Unsure.
				state = State.IDLE
			elif buffer.just_pressed("8") and air_act_count > 0:
				air_act_count -= 1
				state = State.INIT_JUMPING
			else:
				state = State.JUMPING
		
		State.CROUCH_SLASH:
			state = State.CROUCH


# Change movement depending on the state.
func act_state(delta):
	match state:
		State.CLOSE_SLASH:
			velocity.x = 0
			# The move is 28 frames. What is "balance"?
			lock_frames = 27
		
		State.CROUCH_SLASH:
			# TODO: Add actual frame number.
			lock_frames = 10
		
		State.CROUCH:
			velocity.x = 0
		
		State.WALK_FORWARD:
			velocity.x = -SPEED * direction
		
		State.WALK_BACKWARD:
			velocity.x = SPEED * direction
			
		State.IDLE:
			velocity.x = 0;
			
		State.INIT_JUMPING:
			# To handle changing directions last second:
			if buffer.read_action("4", 1):
				velocity.x = SPEED * direction
			elif buffer.read_action("6", 1):
				velocity.x = -SPEED * direction
			else:
				velocity.x = 0
			
			lock_frames = 3;
			velocity.y = JUMP_VELOCITY;

		State.JUMPING:
			if not is_on_floor():
				velocity.y += gravity * delta
