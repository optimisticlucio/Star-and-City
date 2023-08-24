class_name Character

extends CharacterBody2D

# The character's speed.
var SPEED = 300.0
# The character's jumping velocity.
var JUMP_VELOCITY = -400.0
# The amount of actions a player can take in the air (such as jumping again) before being unable to continue.
var AIR_ACTIONS: int = 1

# The animation.
var ANIM: AnimationPlayer

# The current state.
var state = State.IDLE

# Counts the amount of remaining air movement actions left to the player, such as airdashing.
var air_act_count: int = AIR_ACTIONS

# Counts down, once a frame, if we want to have a state that the player can't change from.
var lock_frames = 0

# To handle player input
var input = InputHandler.new()
# For convenience
var buffer = input.buffer

# The states of the character. This is distinct from the keyboard inputs,
# as certain inputs may need to be combined to achieve certain states.
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
	self.scale = Vector2(input.direction, 1)
