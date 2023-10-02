# Handles player input
class_name InputHandler extends Object

# The input buffer's size
const BUFFER_LENGTH = 128

# Enum representing directions. -1 means right, 1 means left.
enum Direction {RIGHT = -1, LEFT = 1}

# Direction the player is currently facing.
var direction := Direction.RIGHT

# The input buffer, to handle inputs.
var buffer := InputBuffer.new()

# Translates between PhysicalInput values to 
var mapping_table: MappedInput


# Class representing the physical buttons a player can press. This is not limited only
# to buttons pressed in a match, and will include pretty much anything that the player
# can use to interact with the virtual enviroment, including macros.
class MappedInput:
	var UP: String
	var RIGHT: String
	var LEFT: String
	var DOWN: String
	var A: String
	var B: String
	var C: String
	
	# Create a new input mapping with default values.
	static func default() -> MappedInput:
		var input = MappedInput.new()
		input.UP = "gamepad_up"
		input.DOWN = "gamepad_down"
		input.LEFT = "gamepad_left"
		input.RIGHT = "gamepad_right"
		input.A = "gamepad_A"
		input.B = "gamepad_B"
		input.C = "gamepad_C"
		return input

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

# Reads the currently pressed input, and puts it into the input buffer.
func calc_input() -> void:
	# If this is a dummy, they should have no inputs.
	if mapping_table == null:
		buffer.set_new_input(VirtualInput.new())
		return
	
	# First let's get what was last pressed, to work with it.
	var last_input = buffer.get_last_input()
	
	# Now we get what was pressed
	var left
	var right
	var up = Input.is_action_pressed(mapping_table.UP)
	var down = Input.is_action_pressed(mapping_table.DOWN)
	var A = Input.is_action_pressed(mapping_table.A)
	var B = Input.is_action_pressed(mapping_table.B)
	var C = Input.is_action_pressed(mapping_table.C)
	
	if direction == Direction.RIGHT:
		left = Input.is_action_pressed(mapping_table.LEFT)
		right = Input.is_action_pressed(mapping_table.RIGHT)
	else:
		right = Input.is_action_pressed(mapping_table.LEFT)
		left = Input.is_action_pressed(mapping_table.RIGHT)
	
	# Now, let's see what we incremate and what we keep in place.
	# TODO - there has got to be a cleaner implementation of BOTH of these sections.
	var new_input := VirtualInput.new()
	
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

# Circular buffer that holds and reads the inputs pressed in the past 64 frames. 
class InputBuffer:
	var buffer_size
	var index: int = 0 
	var past_inputs: Array[VirtualInput] = []

	func _init(size:int = BUFFER_LENGTH):
		# To create an empty input buffer.
		buffer_size = size
		past_inputs.resize(size)
		past_inputs.fill(VirtualInput.new())
	
	# Set a new input into the buffer.
	func set_new_input(new_input: VirtualInput) -> void:
		past_inputs[index] = new_input
		advance_index()
	
	# Moves the index forward. To be used in situations where we want
	# to read an existing input without modifying it, like replays.
	# Returns the new index, for debug purporses.
	func advance_index() -> int:
		index = (index + 1) % buffer_size
		return index
	
	# Get the latest input.
	func get_last_input() -> VirtualInput:
		return past_inputs[(index - 1) % buffer_size]
	
	# Reads if a player did an action, given a certain leniency. 
	# Actions are written in numpad notation, and written as a 2D array where 
	# each entry is [command, leniency].
	#
	# NOTE: From personal testing, here's the ranges leniency should be kept to: 
	#   0 if you want all the buttons pressed at once. 
	#   8 if you want a bit of a strict timing. 
	#   12 if you want for a decently fast timing. 
	#   16 if you want a sweet spot for convenience.
	#   24 if you want it to be possible basically while half asleep.
	func read_action(array: Array) -> bool:
		var action_index = array.size() - 1 # The amount of actions.
		var buffer_index = index - 1 # The current index of the buffer.
		var current_leniency # The leniency. Reassigned as the value is modified.
		
		# Do this for every char in the string, without looping the buffer.
		while action_index >= 0:
			# If we looped the buffer, that's bad.
			if buffer_index == index:
				return false
			
			# Check the leniency.
			current_leniency = array[action_index][1]
			# First, let's see what input we are reading for this time, and insert the
			# appropriate lambda function into this convenient variable.
			var lambda_func
			match array[action_index][0]:
				# Standard numpad inputs.
				"6":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].RIGHT > 0 and past_inputs[b_index].UP == 0
								and past_inputs[b_index].DOWN == 0)
				"7":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].LEFT > 0 and past_inputs[b_index].UP > 0)
				"8":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].UP > 0 and past_inputs[b_index].LEFT == 0
								and past_inputs[b_index].RIGHT == 0)
				"9":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].RIGHT > 0 and past_inputs[b_index].UP > 0)
				"5":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].RIGHT == 0 and past_inputs[b_index].UP == 0 
								and past_inputs[b_index].LEFT == 0 and past_inputs[index].DOWN == 0)
				"4":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].LEFT > 0 and past_inputs[b_index].UP == 0
								and past_inputs[b_index].DOWN == 0)
				"1":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].LEFT > 0 and past_inputs[b_index].DOWN > 0)
				"2":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].DOWN > 0 and past_inputs[b_index].LEFT == 0
								and past_inputs[b_index].RIGHT == 0)
				"3":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].RIGHT > 0 and past_inputs[b_index].DOWN > 0)
				"A":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].A > 0)
				"B":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].B > 0)
				"C":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].C > 0)
				# Inclusive inputs. (As long as [x] is pressed)
				"in2":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].DOWN > 0)
				"in4":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].LEFT > 0)
				"in6":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].RIGHT > 0)
				"in8":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].UP > 0)
				# Holding inputs (Held at least for 60 frames)
				"h2":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].DOWN > 60)
				"h4":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].LEFT > 60)
				# Releasing inputs
				"r2":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].DOWN == 0 
						&& past_input[(b_index - 1) % BUFFER_LENGTH].DOWN > 0)
				"r4":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].LEFT == 0
						&& past_input[(b_index - 1) % BUFFER_LENGTH].DOWN > 0)
				"r6":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].RIGHT == 0
						&& past_input[(b_index - 1) % BUFFER_LENGTH].RIGHT > 0)
				"r8":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].UP == 0
						&& past_input[(b_index - 1) % BUFFER_LENGTH].UP > 0)
				"rA":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].A == 0
						&& past_input[(b_index - 1) % BUFFER_LENGTH].A > 0)
				"rB":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].B == 0
						&& past_input[(b_index - 1) % BUFFER_LENGTH].B > 0)
				"rC":
					lambda_func = func(b_index): 
						return (past_inputs[b_index].C == 0
						&& past_input[(b_index - 1) % BUFFER_LENGTH].C > 0)
				_:
					print("READ_ACTION: Undefined action found - " + array[action_index][0])
					return false
			
			# If not found, kill the loop.
			while current_leniency >= 0:
				if lambda_func.call(buffer_index):
					break
				current_leniency -= 1
				buffer_index = (buffer_index - 1) % buffer_size
					
			if current_leniency < 0:
				return false
			
			action_index -= 1
		
		# If loop was finished and we didn't loop the buffer, return true.
		return true
	
	# Checks if a button was pressed the frame before. Written in numpad notation.
	func just_pressed(key: String) -> bool:
		var last_in = get_last_input()
		match key:
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
				print("JUST_PRESSED: Undefined action found - " + key)
				return false
