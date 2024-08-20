class_name KyState_StunEdge extends CharacterState

var lock_frames := -1

# Set basic variables here!
func _init(calling_char: Character = null):
	STATE_NAME = "Ky Stun Edge"
	STATE_ANIMATION_NAME = "stun_edge"
	
	super._init(calling_char)
	

# Runs when another state changes to this one.
func on_entering_state():
	lock_frames = 59
	CALLING_CHARACTER.phys_rect.reset_movement()
	CALLING_CHARACTER.remove_meter(25_000)

# Determines, given the current game state, which is the next state we should move to.
func determine_next_state() -> CharacterState:
	if lock_frames == 0:
		return KyState_Idle.new(CALLING_CHARACTER)
	return self

# Produces the behavior expected of this state. Does not switch states.
func act_state():
	lock_frames -= 1

# Runs when this state is complete.
func on_exiting_state():
	pass # Nothing changes
