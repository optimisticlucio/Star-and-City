extends Stage

func _ready():
	summon_character(Vector2(200,454), InputHandler.Direction.RIGHT, default_inputs(), "res://img/char/ky/spritesheet1.png")
	#summon_character(Vector2(900,454), InputHandler.Direction.LEFT, "res://img/char/ky/spritesheet2.png")




