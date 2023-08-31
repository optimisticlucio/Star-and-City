class_name Stage extends Node2D

# Characters that can be summoned through the `summon_character()` method.
enum CharacterSummon {TEST_KY}

# The paths to the character.
const CHARACTER_PATHS = {
	CharacterSummon.TEST_KY: preload("../../scenes/char/character_ky.tscn"),
}

# Summon a character to the stage. 
func summon_character(
	character: CharacterSummon,
	location := Vector2(400,500),
	direction := InputHandler.Direction.RIGHT,
	map: InputHandler.MappedInput = null,
	skin := Character.SkinVarient.DEFAULT
) -> Character:
	var player = CHARACTER_PATHS[character].instantiate()
	
	player.input.direction = direction
	player.position = location
	player.input.mapping_table = map
	player.SPRITE_PATH = player.SKIN_PATHS[skin]
	
	add_child(player)

	return player
