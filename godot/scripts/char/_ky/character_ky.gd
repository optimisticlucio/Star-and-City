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
	KNOCKDOWN_STATE = null
	STAND_HIT_STATE = KyState_StandHitStun
	CROUCH_BLOCK_STATE = null
	STAND_BLOCK_STATE = null
	AIR_BLOCK_STATE = null

	super._init(init_pos, init_map, init_skin, init_dir)

# Fires the stun edge projectile
func fire_stun_edge() -> void:
	equip_ego_gift(EGOGifts.Gift.FASTWALK)
	
