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

