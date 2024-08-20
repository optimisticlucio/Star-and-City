class_name CharacterState extends Node 

# A generic "state." Held by characters, which informs them how to act. 

var STATE_NAME: String = "Unnamed State" # For debugging and general info. Fill it in!
var STATE_ANIMATION_NAME: String # The name of the animation in the animation manager.

var CALLING_CHARACTER: Character # The character who this state belongs to.

 # Set basic variables here!
func _init(calling_char: Character = null):
	if calling_char == null:
		push_error("CALLING_CHARACTER MISSING ON %s" % STATE_NAME)
	CALLING_CHARACTER = calling_char

# Runs when another state changes to this one.
func on_entering_state():
	push_error("FUNCTION INCOMPLETE IN %s - on_entering_state()" % STATE_NAME)

# Determines, given the current game state, which is the next state we should move to.
func determine_next_state() -> CharacterState:
	push_error("FUNCTION INCOMPLETE IN %s - determine_next_state()" % STATE_NAME)
	return self # To be clear, this does not happen

# Produces the behavior expected of this state. Does not switch states.
func act_state():
	push_error("FUNCTION INCOMPLETE IN %s - act_state()" % STATE_NAME)

# Runs when this state is complete.
func on_exiting_state():
	push_error("FUNCTION INCOMPLETE IN %s - on_exiting_state()" % STATE_NAME)
