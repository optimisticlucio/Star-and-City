class_name KyState_Crouch extends CharacterState

 # Set basic variables here!
func _init(calling_char: Character = null):
	STATE_NAME = "Ky Crouch"
	STATE_ANIMATION_NAME = "crouch"
	
	super._init(calling_char)
	

# Runs when another state changes to this one.
func on_entering_state():
	CALLING_CHARACTER.attack_hit = false
	CALLING_CHARACTER.phys_rect.reset_movement()

# Determines, given the current game state, which is the next state we should move to.
func determine_next_state() -> CharacterState:
	# Crouch takes precedent over other states!
	# Only exception is jumping or hitstun.
	if not (CALLING_CHARACTER.input.buffer.read_action([["in2", 0]])):
		return KyState_Idle.new(CALLING_CHARACTER)
	elif CALLING_CHARACTER.input.buffer.read_action([["A", 1]]):
		pass #TODO - Return crouch slash
	elif CALLING_CHARACTER.input.buffer.read_action([["B", 1]]):
		pass #TODO - Return crouch kick
	elif CALLING_CHARACTER.input.buffer.read_action([["C", 1]]):
		pass #TODO - Return crouch dust
	return self

# Produces the behavior expected of this state. Does not switch states.
func act_state():
	pass # It don't do shit

# Runs when this state is complete.
func on_exiting_state():
	pass # Nothing changes
