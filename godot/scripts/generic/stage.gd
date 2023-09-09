class_name Stage extends Node2D

# Characters that can be summoned through the `summon_character()` method.
enum CharacterSummon {TEST_KY}

# The current active characters
var player1: Character
var player2: Character

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
	skin := Character.SkinVariant.DEFAULT
) -> Character:
	var player = CHARACTER_PATHS[character].instantiate()
	
	player.input.direction = direction
	player.position = location
	player.input.mapping_table = map
	player.SPRITE_PATH = player.SKIN_PATHS[skin]
	
	add_child(player)

	return player

# Switches the input mapping for player 1 and 2.
func switch_control() -> void:
	var hold = player1.input.mapping_table
	player1.input.mapping_table = player2.input.mapping_table
	player2.input.mapping_table = hold	

# The series of actions taken every virtual frame.
func step(_delta = 0):
	# Calculate the directions of the players.
	player1.determine_direction(player2.global_position)
	player2.determine_direction(player1.global_position)
	
	# Recieve input.
	player1.input.calc_input()
	player2.input.calc_input()
	
	# Check if lock frames are active.
	if (player1.lock_frames == 0):
		# Determine the state.
		player1.determine_state()
	if (player2.lock_frames == 0):
		player2.determine_state()
	
	if (player1.lock_frames == 0):
		# Set the action depending on the state.
		player1.act_state(_delta)
	else:
		player1.lock_frames -= 1
	
	if (player2.lock_frames == 0):
		# Set the action depending on the state.
		player2.act_state(_delta)
	else:
		player2.lock_frames -= 1
	
	# Handle animations
	player1.set_animation()
	player2.set_animation()
	
	player1.move_and_slide()
	player2.move_and_slide()
	

func _physics_process(_delta):
	if Input.is_action_just_pressed("replay_switch"):
		switch_control()
	
	step(_delta)

