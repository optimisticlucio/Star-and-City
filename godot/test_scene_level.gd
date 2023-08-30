extends Stage

var player1: Character
var player2: Character

func _init():
	player1 = summon_character(
		Stage.CharacterSummon.TEST_KY,
		Vector2(200,454),
		InputHandler.Direction.RIGHT,
		default_inputs(),
		Character.SkinVarient.DEFAULT
	)
	
	player2 = summon_character(
		Stage.CharacterSummon.TEST_KY,
		Vector2(900,454),
		InputHandler.Direction.LEFT,
		null,
		Character.SkinVarient.RED
	)
