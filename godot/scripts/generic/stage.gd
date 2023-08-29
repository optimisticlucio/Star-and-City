class_name Stage extends Node2D

const TEST_KY = preload("../../scenes/char/character_ky.tscn")

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

# Summon 
func summon_character(
	location := Vector2(400,500),
	direction = InputHandler.Direction.RIGHT,
	map: InputHandler.MappedInput = null,
	sprite_path: String = "res://img/char/ky/spritesheet1.png"
) -> Character:
	# TODO - Make the character loading flexible
	var player = TEST_KY.instantiate()
	player.input.direction = direction
	player.position = location
	player.input.mapping_table = map
	player.SPRITE_PATH = sprite_path
	add_child(player)

	return player
