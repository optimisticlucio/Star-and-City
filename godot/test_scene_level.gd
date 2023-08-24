extends Node2D

var character_node = preload("res://character_ky_v2.tscn").instantiate()

func _init():
	#summon_character() THIS SHIT BREAKS!
	pass



func summon_character(location: Vector2 = Vector2(0,0), sprite_path: String = "res://img/char/ky/spritesheet1.png"):
	# TODO - Add input mapping handling
	var node = character_node.new(sprite_path)	
	node.position = location
	add_child(node)
