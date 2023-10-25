extends Stage

# Signal is triggered when both character die simultaneously.
func on_double_death():
	# TEMP
	print("Oh no! EVERYONE has died!!!")
	get_tree().paused = true
