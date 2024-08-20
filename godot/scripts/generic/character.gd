class_name Character extends CharacterBody2D

# The maximal amount of super meter a player can have.
const MAX_METER := 100_000

# The default meter the player starts out with.
const DEFAULT_METER := 0

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

# Self-explanatory
var other_player: Character

# Default states for the character 
var IDLE_STATE: GDScript 
var KNOCKDOWN_STATE: GDScript
var STAND_HIT_STATE: GDScript
var CROUCH_BLOCK_STATE: GDScript
var STAND_BLOCK_STATE: GDScript
var AIR_BLOCK_STATE: GDScript

# The current state.
var state: CharacterState

# Counts the amount of remaining air movement actions left to the player, such as airdashing.
var air_act_count: int

# The character's current health.
var current_health: int

# The character's current super meter value. 
var current_meter := DEFAULT_METER

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

# The currently equipped EGO Gifts
var equipped_gifts: Array[EGOGifts.Gift] = []

# Extra functions to run in certain situations.
var extrafunc: ExtraFunc

# The rectangle which represents this character in the physics engine.
var phys_rect: DPhysics.MovingRectangle

# Assumes all extra functions have one parameter - the character.
class ExtraFunc:
	var parent: Character
	var on_hit: Array[Callable]
	var on_hitting: Array[Callable]
	var on_block: Array[Callable]
	
	func _init(init_par: Character):
		parent = init_par
	
	func add_on_hit(x: Callable):
		on_hit.append(x)
	
	func add_on_hitting(x: Callable):
		on_hitting.append(x)
	
	func add_on_block(x: Callable):
		on_block.append(x)
	
	func run_on_hit():
		for x in on_hit:
			x.call(parent)
	
	func run_on_hitting():
		for x in on_hitting:
			x.call(parent)
		
	func run_on_block():
		for x in on_block:
			x.call(parent)

# The states of the character. This is distinct from the keyboard inputs,
# as certain inputs may need to be combined to achieve certain states.
# TODO - Organize this fucking mess.
enum State {
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

func _init(init_pos: Math.Position, init_map: InputHandler.MappedInput = null,
		init_skin := Character.SkinVariant.DEFAULT, init_dir := InputHandler.Direction.RIGHT):
	self.phys_rect = DPhysics.MovingRectangle.new(self, 200, 200, init_pos)
	self.input.mapping_table = init_map
	self.SPRITE_PATH = SKIN_PATHS[init_skin]
	self.input.direction = init_dir
	self.state = IDLE_STATE.new(self)

func _ready():
	# Set the animation player.
	get_node("Sprite2D").texture = load(SPRITE_PATH)
	ANIM = get_node("AnimationPlayer")
	
	extrafunc = ExtraFunc.new(self)
	
	# Set initial values based on initialized values in individual characters.
	air_act_count = AIR_ACTIONS
	current_health = MAX_HEALTH
	
	HURTBOX = get_node("Hurtbox")
	HITBOX = get_node("Hitbox")

# Sets all round-determined values to default.
func reset_round_values():
	current_health = MAX_HEALTH
	current_meter = DEFAULT_METER
	state = IDLE_STATE.new(self)
	air_act_count = AIR_ACTIONS
	
	get_tree().call_group("meterbars", "update")
	get_tree().call_group("healthbars", "update")
	
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
	
	reduce_health(incoming_raw_damage)
	
	if knocks_down:
		# throw this man on the FLOOR
		lock_frames = 35
		state = KNOCKDOWN_STATE.new(self)
	else:
		# Place self into hitstun.
		lock_frames = incoming_hitstun
		state = STAND_HIT_STATE.new(self)
	
	extrafunc.run_on_hit()
	
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
			state = STAND_BLOCK_STATE.new(self)
			lock_frames = stun
			extrafunc.run_on_block()
			return false
		
		if low and input.buffer.read_action([["1", 1]]):
			state = CROUCH_BLOCK_STATE.new(self)
			lock_frames = stun
			extrafunc.run_on_block()
			return false
	
	# If you're in the air this is a completely separate story.
	elif state in [State.JUMPING, State.AIR_BLOCK]:
		var blockable = attack.get_meta("blocked_air")
		var stun = attack.get_meta("blockstun")
		
		if blockable and input.buffer.read_action([["in4", 1]]):
			state = AIR_BLOCK_STATE.new(self)
			lock_frames = stun
			return false
	
	return true

# Runs when the current attack hits someone else.
func notify_attack_connection(granted_meter := 0):
	self.add_meter(granted_meter)
	
	attack_hit = true
	
	extrafunc.run_on_hitting()

# Adds meter to the current character.
func add_meter(added_meter := 0):
	# Add meter and ensure it's not more than the max.
	current_meter = min(MAX_METER, current_meter + added_meter)
	
	# Call for a meterbar update.
	get_tree().call_group("meterbars", "update")

# Removes meter from the current character.
# Returns the amount successfully removed.
func remove_meter(removed_meter := 0) -> int:
	var prev_meter = current_meter
	# Remove meter and ensure it's not less than the min.
	current_meter = max(0, current_meter - removed_meter)
	
	# Call for a meterbar update.
	get_tree().call_group("meterbars", "update")
	
	return prev_meter - current_meter

# Cancels from one attack into the other. Primarily used because of a lot of
# default things we need to reset during a cancel.
func cancel_into(state_switch: CharacterState):
	lock_frames = 0
	attack_hit = false
	state = state_switch

# Reduces health, sends signal if character dies.
func reduce_health(amount: int):
	self.current_health -= calculate_damage(amount, self.damage_tolerance, self.DEFENSE_VALUE)
	
	# Remove one from damage tolerance numerator, unless it'd be zero.
	# TODO - Change this so we can have variable damage scaling
	self.damage_tolerance.dividend = max(self.damage_tolerance.dividend - 1, 1)

# Sets the damage and hitsun of an attack.
func set_attack_values(attack_values: AttackValues) -> void:
	HITBOX.set_meta("damage", attack_values.damage)
	HITBOX.set_meta("hitstun", attack_values.hitstun)
	HITBOX.set_meta("blockstun", attack_values.blockstun)
	HITBOX.set_meta("meter", attack_values.meter)
	HITBOX.set_meta("blocked_high", attack_values.blocked_high)
	HITBOX.set_meta("blocked_low", attack_values.blocked_low)
	HITBOX.set_meta("knocks_down", attack_values.knocks_down)

func equip_ego_gift(gift: EGOGifts.Gift):
	var gift_object = EGOGifts.get_ego(gift)
	
	notify_visuals_add_ego(gift)
	equipped_gifts.append(gift_object)
	gift_object.init_function.call(self)

# Tells the visuals to add the listed ego to the EGO visual.
func notify_visuals_add_ego(gift: EGOGifts.Gift):
	get_node("..").add_ego(self, gift)
	
func determine_state():
	# Check if the state varies. If it does, do exiting_state and entering_state functions.
	var nextState: CharacterState = state.determine_next_state()
	if nextState != state:
		state.on_exiting_state()
		nextState.on_entering_state()
		state = nextState
	
func act_state():
	state.act_state()
