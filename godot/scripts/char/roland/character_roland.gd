class_name Roland extends Character

func _init(init_pos := Math.Position.new(0,0), init_map: InputHandler.MappedInput = null,
		init_skin := Character.SkinVariant.DEFAULT, init_dir := InputHandler.Direction.RIGHT):
	SKIN_PATHS = {
		SkinVariant.DEFAULT: "res://img/char/roland/spritesheet.png"
	}	
	SPEED = 300
	JUMP_VELOCITY = -400
	AIR_ACTIONS = 1
	MAX_HEALTH = 10_000
	DEFENSE_VALUE = Math.Quotient.new(3, 4)

	super._init(init_pos, init_map, init_skin, init_dir)
