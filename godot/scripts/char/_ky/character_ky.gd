class_name KyKiske extends Character

# Extra states 
var exstate: ExState
enum ExState {
	NONE, # For when we aren't doing an ExState. Technically could be removed.
	STUN_EDGE,
	FASTFALL
}

var exstate_animation_name = {
	ExState.NONE: "idle",
	ExState.STUN_EDGE: "stun_edge"
}

func _init(init_pos: Vector2 = Vector2(0,0), init_map: InputHandler.MappedInput = null,
		init_skin := Character.SkinVariant.DEFAULT, init_dir := InputHandler.Direction.RIGHT):
	SKIN_PATHS = {
		SkinVariant.DEFAULT: "res://img/char/_ky/spritesheet1.png",
		SkinVariant.BLUE: "res://img/char/_ky/spritesheet1.png",
		SkinVariant.RED: "res://img/char/_ky/spritesheet2.png",
	}
	SPEED = 300
	JUMP_VELOCITY = -400
	AIR_ACTIONS = 1
	MAX_HEALTH = 10_000
	DEFENSE_VALUE = Math.Quotient.new(3, 4)

	exstate = ExState.NONE
	super._init(init_pos, init_map, init_skin, init_dir)

# Handles starting an animation without inbetween frames.
func start_anim(anim_name: String):
	ANIM.play(anim_name)
	ANIM.pause()

# Changes animation based on current state.
func set_animation():
	var anim_name = ANIM.current_animation
	var next_anim_name
	if state == State.EXSTATE:
		next_anim_name = exstate_animation_name[exstate]
	else:
		next_anim_name = state_animation_name[state]
	if anim_name != next_anim_name and anim_name != ("start_" + next_anim_name):
		start_anim(next_anim_name)
	
	ANIM.advance((1.0/60))

# Determine what the current state of the player is based on the input.
# The transitions of the state machine occur here.
func determine_state():
	# Check the current state to see which state transitions are possible.
	match state:
		State.EXSTATE:
			match exstate:
				ExState.NONE:
					print("ERROR: Entered EXSTATE for no reason! Resetting to IDLE.")
					state = State.IDLE
				
				ExState.STUN_EDGE:
					if can_act():
						state = State.IDLE
						exstate = ExState.NONE

		State.IDLE:
			# Attacks take precedent!
			if current_meter > 25_000 and input.buffer.read_action([["2", 12], ["3", 12], ["6", 12], ["A", 12]]):
				state = State.EXSTATE
				exstate = ExState.STUN_EDGE
			elif input.buffer.read_action([["A", 1]]): 
				state = State.CLOSE_SLASH
			elif input.buffer.read_action([["in2", 0]]):
				state = State.CROUCH
			elif input.buffer.read_action([["4", 0]]):
				state = State.WALK_BACKWARD
			elif input.buffer.read_action([["6", 0]]):
				state = State.WALK_FORWARD
			elif input.buffer.read_action([["in8", 1]]):
				state = State.INIT_JUMPING
		
		State.CLOSE_SLASH:
			# Only runs after the player is immobilized for a few frames
			if can_act():
				state = State.IDLE
		
		State.STAND_BLOCK:
			if can_act():
				state = State.IDLE
		
		State.AIR_BLOCK:
			if can_act():
				state = State.JUMPING
		
		State.CROUCH_BLOCK:
			if can_act():
				state = State.CROUCH
		
		State.CROUCH_SLASH, State.CROUCH_DUST:
			if can_act():
				state = State.CROUCH
				
		State.CROUCH_KICK:
			if input.buffer.read_action([["in2",1], ["C", 0]]) and attack_hit:
				cancel_into(State.CROUCH_DUST)
			if can_act():
				state = State.CROUCH
		
		State.STAND_HIT:
			if can_act():
				state = State.IDLE
				self.damage_tolerance = DAMAGE_TOLERANCE_DEFAULT.duplicate()
		
		State.CROUCH: # Crouch takes precedent over other states!
			# Only exception is jumping or hitstun.
			if not (input.buffer.read_action([["in2", 0]])):
				state = State.IDLE
			elif input.buffer.read_action([["A", 1]]):
				state = State.CROUCH_SLASH
			elif input.buffer.read_action([["B", 1]]):
				state = State.CROUCH_KICK
			elif input.buffer.read_action([["C", 1]]):
				state = State.CROUCH_DUST
		
		State.WALK_FORWARD:
			if input.buffer.read_action([["in2", 0]]):
				state = State.CROUCH
			elif input.buffer.read_action([["in8", 1]]):
				state = State.INIT_JUMPING
			elif input.buffer.read_action([["A", 1]]):
				state = State.CLOSE_SLASH
			elif not input.buffer.read_action([["6", 0]]):
				state = State.IDLE
		
		State.WALK_BACKWARD:
			if input.buffer.read_action([["in2", 0]]):
				state = State.CROUCH
			elif input.buffer.read_action([["in8", 1]]):
				state = State.INIT_JUMPING
			elif input.buffer.read_action([["A", 1]]):
				state = State.CLOSE_SLASH
			elif not input.buffer.read_action([["4", 0]]):
				state = State.IDLE
				
		
		State.INIT_JUMPING:
			if can_act():
				state = State.JUMPING
		
		State.JUMPING:
			# Handle landing
			if is_on_floor():
				air_act_count = AIR_ACTIONS # NOTE - Maybe should be in act? Unsure.
				state = State.IDLE
			elif input.buffer.just_pressed("8") and air_act_count > 0:
				air_act_count -= 1
				state = State.INIT_JUMPING
			elif input.buffer.just_pressed("2"):
				state = State.EXSTATE
				exstate = ExState.FASTFALL
			elif input.buffer.read_action([["C", 1]]):
				state = State.AIR_HEAVY
			else:
				state = State.JUMPING
		
		State.AIR_HEAVY:
			if can_act():
				state = State.JUMPING
			elif is_on_floor():
				# TODO - Convert this into a more convenient "land()", or landing state. prob state.
				lock_frames = 0
				state = State.IDLE


# Change movement depending on the state.
func act_state(delta):
	match state:
		State.EXSTATE:
			# Inner, character-specific state machine.
			match exstate:
				ExState.NONE:
					pass
				
				ExState.STUN_EDGE:
					if can_act(true):
						velocity.x = 0
						lock_frames = 59
						remove_meter(25_000)
				
				ExState.FASTFALL:
					velocity.y = -JUMP_VELOCITY * 2
					velocity.x = 0
					exstate = ExState.NONE
					state = State.JUMPING
		
		State.CLOSE_SLASH:
			if can_act(true):
				set_attack_values(AttackValues.new().set_damage(2000).set_hitstun(40))
				velocity.x = 0
				# The move is 28 frames. What is "balance"?
				lock_frames = 27
		
		State.CROUCH_SLASH:
			if can_act(true):
				set_attack_values(AttackValues.new().set_damage(1000).low_att().met(5000))
				velocity.x = 0
				lock_frames = 35
		
		State.CROUCH_KICK:
			if can_act(true):
				set_attack_values(AttackValues.new().set_damage(200).low_att())
				velocity.x = 0
				lock_frames = 35
		
		State.CROUCH_DUST:
			if can_act(true):
				set_attack_values(AttackValues.new().dam(200).sweep())
				velocity.x = 0
				lock_frames = 32
		
		State.CROUCH:
			attack_hit = false
			velocity.x = 0
		
		State.WALK_FORWARD:
			velocity.x = -SPEED * input.direction
		
		State.WALK_BACKWARD:
			velocity.x = SPEED * input.direction
			
		State.IDLE:
			attack_hit = false
			velocity.x = 0
		
		State.STAND_BLOCK, State.CROUCH_BLOCK, State.KNOCKDOWN:
			if can_act(true):
				state = State.IDLE
			# LATER, once we have a physics engine, add a stagger for each hit.
			velocity.x = 0
		
		State.STAND_HIT:
			if can_act(true):
				state = State.IDLE
			# Right now we don't have a jump hit so
			
			if is_on_floor():
				# Add cool stagger later.
				velocity.x = 0;
			else:
				velocity.y += gravity * delta
			
		State.INIT_JUMPING:
			if can_act(true):
			# To handle changing directions last second:
				if input.buffer.read_action([["in4", 1]]):
					velocity.x = SPEED * input.direction
				elif input.buffer.read_action([["in6", 1]]):
					velocity.x = -SPEED * input.direction
				else:
					velocity.x = 0
			
				lock_frames = 3;
				velocity.y = JUMP_VELOCITY;

		State.JUMPING, State.AIR_BLOCK:
			if not is_on_floor():
				velocity.y += gravity * delta
		
		State.AIR_HEAVY:
			if can_act(true):
				set_attack_values(AttackValues.new().dam(100).hs(40).bs(30).overhead())
				lock_frames = 29
			
			if not is_on_floor():
				velocity.y += gravity * delta

# Fires the stun edge projectile
func fire_stun_edge() -> void:
	equip_ego_gift(EGOGifts.Gift.FASTWALK)
	
