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
# damage. A quotient =1 is baseline, <1 is less damage taken, and >1 is more damage taken.
var DEFENSE_VALUE: Math.Quotient = Math.Quotient.new(1, 1)
# The defaut value for `damage_tolerance` to reset to. See below for further information.
var DAMAGE_TOLERANCE_DEFAULT: Math.Quotient = Math.Quotient.new(8, 8)

# The animation.
var ANIM: AnimationPlayer

# The character's main Hurtbox node.
var HURTBOX: Area2D

# The current state.
var state := State.IDLE

# Counts the amount of remaining air movement actions left to the player, such as airdashing.
var air_act_count: int

# The character's current health.
var current_health: int

# The area2ds that are currently hitting the player. For use in check_damage_collisions.
var currently_coliding_areas := []

# The character's current tolerance to incoming damage. This quantity is
# fluid and changes due to various circumstances in the game, such as
# being in the middle of a combo. Incoming damage is multiplied against
# this value.
var damage_tolerance: Math.Quotient = DAMAGE_TOLERANCE_DEFAULT.duplicate()

# Counts down, once a frame, if we want to have a state that the player can't change from.
var lock_frames := 0

# To handle player input
var input := InputHandler.new()

# The skin/color varient of the character. All characters have the same
# varients to help with the summon_character method's parameters, but
# when we migrate to Rust we could consider each character having their
# own skin/color varients.
enum SkinVariant {DEFAULT, BLUE, RED}

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
	
	HURTBOX = get_node("Hurtbox")
	
	self.scale = Vector2(input.direction, 1)

# Determines which direction the character should be facing.
func determine_direction(opponent_position: Vector2) -> void:
	if self.global_position.x < opponent_position.x:
		self.input.direction = InputHandler.Direction.RIGHT
	else:
		self.input.direction = InputHandler.Direction.LEFT
	
	# Transform animation to match direction, now that it's been updated.	
	transform.x.x = input.direction

# Calculates the damage recieved from another character.
func calculate_damage(
	base_damage: int,
	tolerance_value: Math.Quotient,
	defense_value: Math.Quotient,
) -> int:
	return defense_value.multiply(tolerance_value.multiply(base_damage))

# Triggered when the character is hit.
func on_hit(area: Area2D):
	var attacking_character = area.get_parent()
	var incoming_raw_damage = area.get_meta("damage", 0)
	
	# To avoid being hit by your own attack.
	if attacking_character == self:
		return
	
	self.current_health -= calculate_damage(incoming_raw_damage, self.damage_tolerance, self.DEFENSE_VALUE)
	
	# Remove one from damage tolerance, unless it'd be zero.
	self.damage_tolerance.dividend = max(self.damage_tolerance.dividend - 1, 1)
	
	# Place self into hitstun.
	lock_frames = 10
	state = State.STAND_HIT
	
	# Call for healthbar update.
	get_tree().call_group("healthbars", "update")

# Checks if the player character is being hit by something.
# If they are, triggers on_hit()
func check_damage_collisions():
	# First we get what's currently colliding with our hurtbox.
	var collisions = HURTBOX.get_overlapping_areas()
	
	# Let's go over these collisions. Should be like... at most 3
	# at any given moment. Basically O(1), really.
	for col in collisions:
		# Let's see if we already handled this collision.
		if not col in currently_coliding_areas:
			# If we didn't, let's handle it, and put it on the "ignore" list.
			currently_coliding_areas.append(col)
			on_hit(col)
	
	# We also need garbage disposal for currently_coliding_areas.
	# If we stop colliding with something, let's be ready for it.
	for loc in currently_coliding_areas:
		if not loc in collisions:
			currently_coliding_areas.erase(loc)
