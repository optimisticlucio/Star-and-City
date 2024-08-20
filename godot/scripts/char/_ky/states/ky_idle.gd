class_name KyState_Idle extends CharacterState

 # Set basic variables here!
func _init(calling_char: Character = null):
	STATE_NAME = "Ky Idle"
	STATE_ANIMATION_NAME = "idle"
	
	super._init(calling_char)
	

# Runs when another state changes to this one.
func on_entering_state():
	CALLING_CHARACTER.attack_hit = false
	CALLING_CHARACTER.phys_rect.reset_movement()

# Determines, given the current game state, which is the next state we should move to.
func determine_next_state() -> CharacterState:
	# Attacks take precedent!
	if CALLING_CHARACTER.current_meter > 25_000 and CALLING_CHARACTER.input.buffer.read_action([["2", 12], ["3", 12], ["6", 12], ["A", 12]]):
		return KyState_StunEdge.new(CALLING_CHARACTER)
	elif CALLING_CHARACTER.input.buffer.read_action([["A", 1]]): 
		return KyState_CloseSlash.new(CALLING_CHARACTER)
	elif CALLING_CHARACTER.input.buffer.read_action([["in2", 0]]):
		return KyState_Crouch.new(CALLING_CHARACTER)
	elif CALLING_CHARACTER.input.buffer.read_action([["4", 0]]):
		return KyState_BackwardsWalk.new(CALLING_CHARACTER)
	elif CALLING_CHARACTER.input.buffer.read_action([["6", 0]]):
		return KyState_ForwardWalk.new(CALLING_CHARACTER)
	elif CALLING_CHARACTER.input.buffer.read_action([["in8", 1]]):
		pass # TODO - Move to Jump
	return self

# Produces the behavior expected of this state. Does not switch states.
func act_state():
	pass # It don't do shit

# Runs when this state is complete.
func on_exiting_state():
	pass # Nothing changes
