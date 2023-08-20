extends CharacterBody2D

# The character's speed.
const SPEED = 300.0
# The character's jumping velocity.
const JUMP_VELOCITY = -400.0
# The input buffer's size
const BUFFER_LENGTH = 64

# The animation.
var ANIM: AnimationPlayer

# The current state.
var state = State.IDLE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Counts the amount of remaining air movement actions left to the player, such as airdashing.
var air_act_count: int

# Counts down, once a frame, if we want to have a state that the player can't change from.
var lock_frames = 0

# Enum representing directions. -1 means right, 1 means left.
enum Direction {RIGHT = -1, LEFT = 1}

# Direction the player is currently facing.
var direction: Direction = Direction.RIGHT

# The input buffer, to handle inputs.
var buffer = InputBuffer.new()

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
	var index = 0 
	var past_inputs = []
	
	func _init():
		# To create an empty, 64 input buffer.d
		past_inputs.resize(BUFFER_LENGTH)
		past_inputs.fill(VirtualInput.new())
	
	func set_new_input(new_input: VirtualInput) -> void:
		past_inputs[index] = new_input
		index = (index + 1) % BUFFER_LENGTH
	
	func get_last_input() -> VirtualInput:
		return past_inputs[(index - 1) % BUFFER_LENGTH]
	
	# Reads if a player did an action, given a certain leniency. 
	# Actions are written in numpad notation.
	func read_action(action: String, leniency: int) -> bool:
		var action_index = action.length() - 1
		var buffer_index = index - 1
		var endpoint = (index + 1) % BUFFER_LENGTH # To not do this calculation every loop
		var current_leniency = leniency
		
		# Do this for every char in the string, without looping the buffer.
		while action_index != -1:
			# If we looped the buffer, that's bad.
			if buffer_index == endpoint:
				return false
			
			# For every possible input, look for the input we want in the past [leniency] frames.
			# If not found, kill the loop.
			match action[action_index]:
				"6":
					while current_leniency > 0:
						if past_inputs[buffer_index].RIGHT > 0:
							break
						current_leniency -= 1
						buffer_index = (buffer_index - 1) % BUFFER_LENGTH
				"8":
					while current_leniency > 0:
						if past_inputs[buffer_index].UP > 0:
							break
						current_leniency -= 1
						buffer_index = (buffer_index - 1) % BUFFER_LENGTH
				"4":
					while current_leniency > 0:
						if past_inputs[buffer_index].LEFT > 0:
							break
						current_leniency -= 1
						buffer_index = (buffer_index - 1) % BUFFER_LENGTH
				"2":
					while current_leniency > 0:
						if past_inputs[buffer_index].DOWN > 0:
							break
						current_leniency -= 1
						buffer_index = (buffer_index - 1) % BUFFER_LENGTH
				"A":
					while current_leniency > 0:
						if past_inputs[buffer_index].A > 0:
							break
						current_leniency -= 1
						buffer_index = (buffer_index - 1) % BUFFER_LENGTH
				_:
					print("READ_ACTION: Undefined action found - " + action[action_index])
					return false
					
			if current_leniency == 0:
				return false
			
			action_index -= 1
		
		# If loop was finished and we didn't loop the buffer, return true.
		return true

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
				air_act_count = 1 # NOTE - Maybe should be in act? Unsure.
				state = State.IDLE
			elif buffer.read_action("8", 1) and air_act_count > 0:
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
			
			lock_frames = 8; # TODO - This is set to 8 because right now we are
			# only reading when the button is pressed. Later on when jumping is
			# changed to when Jump is initially pressed rather than held at all,
			# change this to like 3 or 4.
			velocity.y = JUMP_VELOCITY;

		State.JUMPING:
			if not is_on_floor():
				velocity.y += gravity * delta
