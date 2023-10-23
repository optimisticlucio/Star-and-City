extends Stage

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
