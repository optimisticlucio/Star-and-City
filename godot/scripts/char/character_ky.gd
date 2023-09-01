class_name KyKiske extends Character

# Ky's skin varients.
const SKIN_PATHS = {
	SkinVarient.DEFAULT: "res://img/char/ky/spritesheet1.png",
	SkinVarient.BLUE: "res://img/char/ky/spritesheet1.png",
	SkinVarient.RED: "res://img/char/ky/spritesheet2.png",
}

func _init():
	SPRITE_PATH = SKIN_PATHS[SkinVarient.BLUE]
	SPEED = 300
	JUMP_VELOCITY = -400
	AIR_ACTIONS = 1
	MAX_HEALTH = 10_000

# Handles starting an animation with or without inbetween frames.
func start_anim(anim_name: String):
	if ANIM.has_animation("start_" + anim_name):
		ANIM.play("start_" + anim_name)
		ANIM.queue(anim_name)
	else:
		ANIM.play(anim_name)

func _physics_process(delta):
	input.calc_input()
	
	# Check if lock frames are active.
	if (lock_frames == 0):
		# Determine the state.
		determine_state()
	
		# Set the action depending on the state.
		act_state(delta)
	else:
		lock_frames -= 1
	
	# Handle animation
	var anim_name = ANIM.current_animation
	var next_anim_name = state_animation_name[state]
	if anim_name != next_anim_name and anim_name != ("start_" + next_anim_name):
		print("STATE: Changed from " + anim_name + " to " + next_anim_name)
		start_anim(next_anim_name)

	move_and_slide()

# Determine what the current state of the player is based on the input.
# The transitions of the state machine occur here.
func determine_state():
	# Check the current state to see which state transitions are possible.
	match state:
		State.IDLE:
			if buffer.read_action("A", 1): 
				# Attacks take precedent!
				state = State.CLOSE_SLASH
			elif buffer.read_action("2", 1) or buffer.read_action("1",1) or buffer.read_action("3",1):
				state = State.CROUCH
			elif buffer.read_action("4", 1):
				state = State.WALK_BACKWARD
			elif buffer.read_action("6", 1):
				state = State.WALK_FORWARD
			elif buffer.read_action("7", 1) or buffer.read_action("8",1) or buffer.read_action("9",1):
				state = State.INIT_JUMPING
		
		State.CLOSE_SLASH:
			# Only runs after the player is immobilized for a few frames
			state = State.CROUCH
		
		State.CROUCH_SLASH:
			state = State.CROUCH
		
		State.CROUCH: # Crouch takes precedent over other states!
			# Only exception is jumping or hitstun.
			if not (buffer.read_action("2", 1) or buffer.read_action("1",1) or buffer.read_action("3",1)):
				state = State.IDLE
			elif buffer.read_action("A", 1):
				state = State.CROUCH_SLASH
		
		State.WALK_FORWARD:
			if buffer.read_action("2", 1) or buffer.read_action("1",1) or buffer.read_action("3",1):
				state = State.CROUCH
			elif buffer.read_action("7", 1) or buffer.read_action("8",1) or buffer.read_action("9",1):
				state = State.INIT_JUMPING
			elif buffer.read_action("A", 1):
				state = State.CLOSE_SLASH
			elif not buffer.read_action("6", 1):
				state = State.IDLE
		
		State.WALK_BACKWARD:
			if buffer.read_action("2", 1):
				state = State.CROUCH
			elif buffer.read_action("7", 1) or buffer.read_action("8",1) or buffer.read_action("9",1):
				state = State.INIT_JUMPING
			elif buffer.read_action("A", 1):
				state = State.CLOSE_SLASH
			elif not buffer.read_action("4", 1):
				state = State.IDLE
				
		
		State.INIT_JUMPING:
			state = State.JUMPING
		
		State.JUMPING:
			# Handle landing
			if is_on_floor():
				air_act_count = AIR_ACTIONS # NOTE - Maybe should be in act? Unsure.
				state = State.IDLE
			elif buffer.just_pressed("8") and air_act_count > 0:
				air_act_count -= 1
				state = State.INIT_JUMPING
			else:
				state = State.JUMPING


# Change movement depending on the state.
func act_state(delta):
	match state:
		State.CLOSE_SLASH:
			velocity.x = 0
			# The move is 28 frames. What is "balance"?
			lock_frames = 27
		
		State.CROUCH_SLASH:
			velocity.x = 0
			lock_frames = 35
		
		State.CROUCH:
			velocity.x = 0
		
		State.WALK_FORWARD:
			velocity.x = -SPEED * input.direction
		
		State.WALK_BACKWARD:
			velocity.x = SPEED * input.direction
			
		State.IDLE:
			velocity.x = 0;
			
		State.INIT_JUMPING:
			# To handle changing directions last second:
			if buffer.read_action("4", 1) or buffer.read_action("7", 1):
				velocity.x = SPEED * input.direction
			elif buffer.read_action("6", 1) or buffer.read_action("9", 1):
				velocity.x = -SPEED * input.direction
			else:
				velocity.x = 0
			
			lock_frames = 3;
			velocity.y = JUMP_VELOCITY;

		State.JUMPING:
			if not is_on_floor():
				velocity.y += gravity * delta


func on_hit(_area):
	# To avoid being hit by your own attack.
	if _area.get_parent() == self:
		return
		
	self.current_health -= 100
	get_tree().call_group("healthbars", "update")
