class_name KyState_CloseSlash extends CharacterState

 # Set basic variables here!
func _init(calling_char: Character = null):
	STATE_NAME = "Ky Close Slash"
	STATE_ANIMATION_NAME = "closeslash"
	
	super._init(calling_char)
	
var lock_frames := -1

# Runs when another state changes to this one.
func on_entering_state():
	CALLING_CHARACTER.set_attack_values(AttackValues.new().set_damage(2000).set_hitstun(40))
	CALLING_CHARACTER.phys_rect.reset_movement()
	# The move is 27 frames. What is "balance"?
	lock_frames = 27

# Determines, given the current game state, which is the next state we should move to.
func determine_next_state() -> CharacterState:
	# Attacks take precedent!
	if lock_frames == 0:
		return KyState_Idle.new(CALLING_CHARACTER)
	return self

# Produces the behavior expected of this state. Does not switch states.
func act_state():
	lock_frames -= 1

# Runs when this state is complete.
func on_exiting_state():
	pass # Nothing changes
