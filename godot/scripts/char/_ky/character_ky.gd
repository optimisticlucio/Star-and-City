class_name KyKiske extends Character

func _init(init_pos := Math.Position.new(0,0), init_map: InputHandler.MappedInput = null,
		init_skin := Character.SkinVariant.DEFAULT, init_dir := InputHandler.Direction.RIGHT):
	SKIN_PATHS = {
		SkinVariant.DEFAULT: "res://img/char/_ky/spritesheet1.png",
		SkinVariant.BLUE: "res://img/char/_ky/spritesheet1.png",
		SkinVariant.RED: "res://img/char/_ky/spritesheet2.png",
	}
	SPEED = 50
	JUMP_VELOCITY = -100
	AIR_ACTIONS = 1
	MAX_HEALTH = 10_000
	DEFENSE_VALUE = Math.Quotient.new(3, 4)
	
	IDLE_STATE = KyState_Idle

	super._init(init_pos, init_map, init_skin, init_dir)

# Handles starting an animation without inbetween frames.
func start_anim(anim_name: String):
	ANIM.play(anim_name)
	ANIM.pause()

# Changes animation based on current state.
func set_animation():
	var anim_name = ANIM.current_animation
	var next_anim_name
	next_anim_name = state.STATE_ANIMATION_NAME
	if anim_name != next_anim_name and anim_name != ("start_" + next_anim_name):
		start_anim(next_anim_name)
	
	ANIM.advance((1.0/60))

# Fires the stun edge projectile
func fire_stun_edge() -> void:
	equip_ego_gift(EGOGifts.Gift.FASTWALK)
	
