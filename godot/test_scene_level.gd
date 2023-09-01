extends Stage

var player1: Character
var player2: Character

func _init():
	player1 = summon_character(
		Stage.CharacterSummon.TEST_KY,
		Vector2(200,454),
		InputHandler.Direction.RIGHT,
		InputHandler.MappedInput.default(),
		Character.SkinVarient.DEFAULT
	)
	
	player2 = summon_character(
		Stage.CharacterSummon.TEST_KY,
		Vector2(900,454),
		InputHandler.Direction.LEFT,
		null,
		Character.SkinVarient.RED
	)

# Signal is triggered when a single character dies.
func on_character_death(character):
	# TEMP
	print("Oh no! %s has died!" % character.name)
	get_tree().paused = true

# Signal is triggered when both character die simultaneously.
func on_double_death():
	# TEMP
	print("Oh no! EVERYONE has died!!!")
	get_tree().paused = true
