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

# -------------- record function ------------
var controlling_p1 := true
var is_recording := false
var rec_playing := false
var rec_index: int
var record_length: int
var rec_buffer := InputHandler.InputBuffer.new()

# Switches the input mapping for player 1 and 2.
func switch_control() -> void:
	controlling_p1 = not controlling_p1
	var hold = player1.input.mapping_table
	player1.input.mapping_table = player2.input.mapping_table
	player2.input.mapping_table = hold	

# begins recording which needs to be stopped later.
# Returns length of recording buffer.
func begin_recording() -> int:
	is_recording = true
	var rec_length = InputHandler.BUFFER_LENGTH * 4
	var new_buffer = InputHandler.InputBuffer.new(rec_length)
	
	if controlling_p1:
		player1.input.buffer = new_buffer
	else:
		player2.input.buffer = new_buffer
	
	rec_index = 0
	return rec_length

# Stops a currently running recording. Returns the end-index of the recording.
func end_recording():
	is_recording = false
	
	var end_index = rec_index
	rec_index = 0
	
	if controlling_p1:
		rec_buffer = player1.input.buffer
	else:
		rec_buffer = player2.input.buffer
	
	rec_buffer.index = 0
	
	return end_index

func play_recording():
	# TODO - Somehow override the input handler to just step forward.
	pass

func pause_recording():
	pass

# ---------------

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
	if not is_recording:
		if rec_playing:
			if Input.is_action_just_pressed("replay_play"):
				pause_recording()
		else:
			if Input.is_action_just_pressed("replay_switch"):
				switch_control()
	
			if Input.is_action_just_pressed("replay_start"):
				record_length = begin_recording()
		
			if Input.is_action_just_pressed("replay_play"):
				play_recording()
	
	else:
		rec_index+=1
		
		if rec_index == record_length or Input.is_action_just_pressed("replay_start"):
			end_recording()
		
	
	step(_delta)

