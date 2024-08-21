class_name KyState_StandHitStun extends CharacterState

 # Set basic variables here!
func _init(calling_char: Character = null):
	STATE_NAME = "Ky Standing HitStun"
	STATE_ANIMATION_NAME = "stand_hitstun"
	
	super._init(calling_char)

var remaining_hitstun: int = -1

# Runs when another state changes to this one.
func on_entering_state():
	pass

# Determines, given the current game state, which is the next state we should move to.
func determine_next_state() -> CharacterState:
	if remaining_hitstun == 0:
		return KyState_Idle.new(CALLING_CHARACTER)
	return self

# Produces the behavior expected of this state. Does not switch states.
func act_state():
	remaining_hitstun -= 1

# Runs when this state is complete.
func on_exiting_state():
	pass # Nothing changes

# Tells us how much hitstun!
func give_state_int(input: int):
	remaining_hitstun = input
