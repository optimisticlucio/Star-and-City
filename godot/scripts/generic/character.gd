class_name Character extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# The character's spritesheet, to reveal to the editor.
var SPRITE_PATH: String

# The character's speed.
var SPEED: int
# The character's jumping velocity.
var JUMP_VELOCITY: int
# The amount of actions a player can take in the air (such as jumping again) before being unable to continue.
var AIR_ACTIONS: int
# The character's maximum health.
var MAX_HEALTH: int
# The character's defense. This is multiplied against any incoming
# damage. 1 is default; <1 is reduced damage; >1 is increased damage.
var DEFENSE_VALUE: float = 1

# The animation.
var ANIM: AnimationPlayer

# The current state.
var state := State.IDLE

# Counts the amount of remaining air movement actions left to the player, such as airdashing.
var air_act_count: int

# The chatacyer's current health.
var current_health: int

# Counts down, once a frame, if we want to have a state that the player can't change from.
var lock_frames := 0

# To handle player input
var input := InputHandler.new()
# For convenience
var buffer := input.buffer

# The skin/color varient of the character. All characters have the same
# varients to help with the summon_character method's parameters, but
# when we migrate to Rust we could consider each character having their
# own skin/color varients.
enum SkinVarient {DEFAULT, BLUE, RED}

# The states of the character. This is distinct from the keyboard inputs,
# as certain inputs may need to be combined to achieve certain states.
enum State {IDLE, CROUCH, WALK_FORWARD, WALK_BACKWARD, JUMPING, INIT_JUMPING, CLOSE_SLASH, CROUCH_SLASH, STAND_HIT}

# The animation name of the State.
var state_animation_name = {
	State.IDLE: "idle",
	State.CROUCH: "crouch",
	State.WALK_FORWARD: "walk forward",
	State.WALK_BACKWARD: "walk backward",
	State.JUMPING: "jumping",
	State.INIT_JUMPING: "jumping",
	State.CLOSE_SLASH: "closeslash",
	State.CROUCH_SLASH: "crouchslash",
	State.STAND_HIT: "stand_hitstun"
}

func _ready():
	# Set the animation player.
	get_node("Sprite2D").texture = load(SPRITE_PATH)
	ANIM = get_node("AnimationPlayer")
	
	# Set initial values based on initialized values in individual characters.
	air_act_count = AIR_ACTIONS
	current_health = MAX_HEALTH
	
	self.scale = Vector2(input.direction, 1)

# Calculates the damage recieved from another character.
# NOTE: The behavior of `int()` is to discard the remainder of the division.
#   Presumably, this isn't going to impact us much since we're using only very small
#   divisors, but if it does we can swap it out.
# TODO: Add combo multipliers.
func calculate_damage(
	base_damage: int,
	defense_value: float
) -> int:
	return int(base_damage * defense_value)

# Triggered when the character is hit.
func on_hit(area):
	var attacking_character = area.get_parent()
	
	# To avoid being hit by your own attack.
	if attacking_character == self:
		return
	
	# TODO: Get actual damage value from opponent.
	self.current_health -= calculate_damage(1000, self.DEFENSE_VALUE)
	
	# Place self into hitstun.
	lock_frames = 10
	state = State.STAND_HIT
	
	# Call for healthbar update.
	get_tree().call_group("healthbars", "update")
