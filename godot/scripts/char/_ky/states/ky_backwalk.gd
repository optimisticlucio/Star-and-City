class_name KyState_BackwardsWalk extends CharacterState

 # Set basic variables here!
func _init(calling_char: Character = null):
	STATE_NAME = "Ky Walk Back"
	STATE_ANIMATION_NAME = "walk backward"
	
	super._init(calling_char)
	

# Runs when another state changes to this one.
func on_entering_state():
	pass 

# Determines, given the current game state, which is the next state we should move to.
func determine_next_state() -> CharacterState:
	if CALLING_CHARACTER.input.buffer.read_action([["in2", 0]]):
		return KyState_Crouch.new(CALLING_CHARACTER)
	elif CALLING_CHARACTER.input.buffer.read_action([["in8", 1]]):
		# TODO - Set state to jump
		pass
	elif CALLING_CHARACTER.input.buffer.read_action([["A", 1]]):
		return KyState_CloseSlash.new(CALLING_CHARACTER)
	elif not CALLING_CHARACTER.input.buffer.read_action([["4", 0]]):
		return KyState_Idle.new(CALLING_CHARACTER)
	return self

# Produces the behavior expected of this state. Does not switch states.
func act_state():
	CALLING_CHARACTER.phys_rect.velocity.x = CALLING_CHARACTER.SPEED * CALLING_CHARACTER.input.direction

# Runs when this state is complete.
func on_exiting_state():
	pass # Nothing changes
