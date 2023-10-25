class_name Character extends CharacterBody2D

# The maximal amount of super meter a player can have.
const MAX_METER := 100_000

# The default meter the player starts out with.
const DEFAULT_METER := 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# The character's spritesheet, to reveal to the editor.
var SPRITE_PATH: String

# The various skins a character can have. To be set in child!
var SKIN_PATHS: Dictionary

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

# The character's main Hitbox node.
var HITBOX: Area2D

# The current state.
var state := State.IDLE

# Counts the amount of remaining air movement actions left to the player, such as airdashing.
var air_act_count: int

# The character's current health.
var current_health: int

# The character's current super meter value. 
var current_meter := 0

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

# This is true IFF we are mid attack animation, and said attack hit the opponent.
var attack_hit := false

# The skin/color varient of the character. All characters have the same
# varients to help with the summon_character method's parameters, but
# when we migrate to Rust we could consider each character having their
# own skin/color varients.
enum SkinVariant {DEFAULT, BLUE, RED}

# The states of the character. This is distinct from the keyboard inputs,
# as certain inputs may need to be combined to achieve certain states.
# TODO - Organize this fucking mess.
enum State {
	EXSTATE, # This state represents any custom per-character states.
	PREVIEW, # For situations when we need to present the character and do nothing.
	IDLE,
	CROUCH,
	STAND_BLOCK,
	CROUCH_BLOCK,
	AIR_BLOCK,
	WALK_FORWARD,
	WALK_BACKWARD,
	JUMPING,
	INIT_JUMPING,
	KNOCKDOWN,
	STAND_HIT,
	CROUCH_KICK,
	CROUCH_DUST,
	CLOSE_SLASH,
	CROUCH_SLASH,
	AIR_HEAVY
}

# The animation name of the State.
var state_animation_name = {
	State.PREVIEW: "idle",
	State.IDLE: "idle",
	State.CROUCH: "crouch",
	State.WALK_FORWARD: "walk forward",
	State.WALK_BACKWARD: "walk backward",
	State.JUMPING: "jumping",
	State.INIT_JUMPING: "jumping",
	State.CLOSE_SLASH: "closeslash",
	State.CROUCH_SLASH: "crouchslash",
	State.STAND_HIT: "stand_hitstun",
	State.STAND_BLOCK: "stand_block",
	State.CROUCH_BLOCK: "crouch_block",
	State.AIR_BLOCK: "air_block",
	State.CROUCH_KICK: "crouch_kick",
	State.CROUCH_DUST: "crouch_dust",
	State.KNOCKDOWN: "knockdown",
	State.AIR_HEAVY: "air_heavy"
}

func _init(init_pos: Vector2, init_map: InputHandler.MappedInput = null,
		init_skin := Character.SkinVariant.DEFAULT, init_dir := InputHandler.Direction.RIGHT):
	self.position = init_pos
	self.input.mapping_table = init_map
	self.SPRITE_PATH = SKIN_PATHS[init_skin]
	self.input.direction = init_dir

func _ready():
	# Set the animation player.
	get_node("Sprite2D").texture = load(SPRITE_PATH)
	ANIM = get_node("AnimationPlayer")
	
	# Set initial values based on initialized values in individual characters.
	air_act_count = AIR_ACTIONS
	current_health = MAX_HEALTH
	
	HURTBOX = get_node("Hurtbox")
	HITBOX = get_node("Hitbox")
	
# Changes the direction the character is facing
func change_direction(dir: InputHandler.Direction):
	self.input.direction = dir
	transform.x.x = dir

# Determines which direction the character should be facing.
func determine_direction(opponent_position: Vector2) -> void:
	if self.global_position.x < opponent_position.x:
		change_direction(InputHandler.Direction.RIGHT)
	else:
		change_direction(InputHandler.Direction.LEFT)

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
	var incoming_hitstun = area.get_meta("hitstun", 10)
	var knocks_down = area.get_meta("knocks_down", false)
	var opponent_meter_granted = area.get_meta("meter", 0)
	
	# To avoid being hit by your own attack.
	if attacking_character == self:
		return
	
	# Let's tell whoever hit us "good job," have some meter, as a treat.
	attacking_character.notify_attack_connection(opponent_meter_granted)
	
	self.current_health -= calculate_damage(incoming_raw_damage, self.damage_tolerance, self.DEFENSE_VALUE)
	
	# Remove one from damage tolerance, unless it'd be zero.
	self.damage_tolerance.dividend = max(self.damage_tolerance.dividend - 1, 1)
	
	if knocks_down:
		# throw this man on the FLOOR
		lock_frames = 35
		state = State.KNOCKDOWN
	else:
		# Place self into hitstun.
		lock_frames = incoming_hitstun
		state = State.STAND_HIT
	
	# Call for healthbar update.
	get_tree().call_group("healthbars", "update")

# Checks if the player character is being hit by something.
# If they are, triggers on_hit().
func check_damage_collisions():
	# First we get what's currently colliding with our hurtbox.
	var collisions = HURTBOX.get_overlapping_areas()
	
	# Let's go over these collisions. Should be like... at most 3
	# at any given moment.
	for col in collisions:
		# Let's see if we already handled this collision.
		if not col in currently_coliding_areas:
			# If we didn't, let's handle it, and put it on the "ignore" list.
			currently_coliding_areas.append(col)
			
			if is_hit_by_attack(col):
				on_hit(col)
	
	# We also need garbage disposal for currently_coliding_areas.
	# If we stop colliding with something, let's be ready for it.
	for col in currently_coliding_areas:
		if not col in collisions:
			currently_coliding_areas.erase(col)

# Returns true if the character isn't currently in a state which stops most inputs.
func can_act(increment := false) -> bool:
	if lock_frames > 0:
		if increment:
			lock_frames -= 1
		return false
	return true

# Checks whether a given attack would successfully hit our character.
func is_hit_by_attack(attack: Area2D) -> bool:
	# You can only block from passive states. Maybe movement if you're quick.
	if state in [State.IDLE, State.WALK_FORWARD, State.WALK_BACKWARD, State.CROUCH, 
				State.STAND_BLOCK, State.CROUCH_BLOCK]: 
		var high = attack.get_meta("blocked_high")
		var low = attack.get_meta("blocked_low")
		var stun = attack.get_meta("blockstun")
		
		if high and input.buffer.read_action([["4", 1]]):
			state = State.STAND_BLOCK
			lock_frames = stun
			return false
		
		if low and input.buffer.read_action([["1", 1]]):
			state = State.CROUCH_BLOCK
			lock_frames = stun
			return false
	
	# If you're in the air this is a completely separate story.
	elif state in [State.JUMPING, State.AIR_BLOCK]:
		var blockable = attack.get_meta("blocked_air")
		var stun = attack.get_meta("blockstun")
		
		if blockable and input.buffer.read_action([["in4", 1]]):
			state = State.AIR_BLOCK
			lock_frames = stun
			return false
	
	return true

# Runs when the current attack hits someone else.
func notify_attack_connection(granted_meter := 0):
	# Add meter upon attack connection, and ensure it's not more than the max.
	current_meter = min(MAX_METER, current_meter + granted_meter)
	
	# Call for a meterbar update.
	get_tree().call_group("meterbars", "update")
	
	attack_hit = true

# Cancels from one attack into the other. Primarily used because of a lot of
# default things we need to reset during a cancel.
func cancel_into(state_switch: State):
	lock_frames = 0
	attack_hit = false
	state = state_switch

# Sets the damage and hitsun of an attack.
func set_attack_values(attack_values: AttackValues) -> void:
	HITBOX.set_meta("damage", attack_values.damage)
	HITBOX.set_meta("hitstun", attack_values.hitstun)
	HITBOX.set_meta("blockstun", attack_values.blockstun)
	HITBOX.set_meta("meter", attack_values.meter)
	HITBOX.set_meta("blocked_high", attack_values.blocked_high)
	HITBOX.set_meta("blocked_low", attack_values.blocked_low)
	HITBOX.set_meta("knocks_down", attack_values.knocks_down)
	
