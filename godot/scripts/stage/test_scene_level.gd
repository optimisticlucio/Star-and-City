extends Stage

func _init():
	player1 = summon_character(
		Global.PlayableCharacter.TEST_KY,
		Vector2(200,454),
		InputHandler.Direction.RIGHT,
		InputHandler.MappedInput.default(),
		Character.SkinVariant.DEFAULT
	)
	
	player2 = summon_character(
		Global.PlayableCharacter.TEST_KY,
		Vector2(900,454),
		InputHandler.Direction.LEFT,
		null,
		Character.SkinVariant.RED
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
