extends Stage

var player1: Character
var player2: Character

func _init():
	player1 = summon_character(Vector2(200,454), InputHandler.Direction.RIGHT, default_inputs(), "res://img/char/ky/spritesheet1.png")
	player2 = summon_character(Vector2(900,454), InputHandler.Direction.LEFT, null, "res://img/char/ky/spritesheet2.png")
