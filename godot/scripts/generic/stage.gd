class_name Stage extends Node2D

# Characters that can be summoned through the `summon_character()` method.
enum CharacterSummon {TEST_KY}

# The paths to the character.
const CHARACTER_PATHS = {
	CharacterSummon.TEST_KY: preload("../../scenes/char/character_ky.tscn"),
}

# Primarily for testing.
func default_inputs() -> InputHandler.MappedInput:
	var input = InputHandler.MappedInput.new()
	input.UP = "gamepad_up"
	input.DOWN = "gamepad_down"
	input.LEFT = "gamepad_left"
	input.RIGHT = "gamepad_right"
	input.A = "gamepad_A"
	input.B = "gamepad_B"
	input.C = "gamepad_C"
	return input

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
	player.SPRITE_PATH = KyKiske.SKIN_PATHS[skin]
	
	add_child(player)

	return player
