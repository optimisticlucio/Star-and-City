extends Node

# THIS SCRIPT IS ALWAYS LOADED. ALWAYS.
enum PlayableCharacter {TEST_KY, ROLAND, ARGALIA}

class ChosenChar:
	var character: PackedScene
	var skin: Character.SkinVariant
	
	func _init(in_char := preload("res://scenes/char/_ky/character_ky.tscn"), in_skin := Character.SkinVariant.DEFAULT):
		character = in_char
		skin = in_skin

var p1_char := ChosenChar.new()
var p2_char := ChosenChar.new()

# Loads characters and switches scenes.
func StartGame(discard_scene: Node, stage_path: PackedScene = load("res://scenes/stage/test_scene_level.tscn")):
	# Discard the previous scene.
	discard_scene.free()
	# Load up the stage
	var stage = stage_path.instantiate()
	get_tree().root.add_child(stage)
