extends Node

# THIS SCRIPT IS ALWAYS LOADED. ALWAYS.
enum PlayableCharacter {TEST_KY, ROLAND, ARGALIA}

# Loads characters and switches scenes. Assumes prev root node was freed already.
func StartGame(p1: PlayableCharacter, p2: PlayableCharacter,
			stage_path: PackedScene = load("res://scenes/stage/test_scene_level.tscn")):
	# Load up the stage
	var stage = stage_path.instantiate()
	get_tree().root.add_child(stage)
	
	# Now summon the relevant characters.
	stage.summon_character(p1)
	stage.summon_character(p2, Vector2(800,500), InputHandler.Direction.LEFT)
