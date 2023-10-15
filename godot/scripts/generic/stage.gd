class_name Stage extends Node2D

# Characters that can be summoned through the `summon_character()` method.
enum CharacterSummon {TEST_KY}

# The current active characters
var player1: Character
var player2: Character

# For recording purposes
var rec: Recording

# The paths to the character.
const CHARACTER_PATHS = {
	CharacterSummon.TEST_KY: preload("../../scenes/char/_ky/character_ky.tscn"),
}

func _ready():
	rec = Recording.new(player1, player2)

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

# The series of actions taken every virtual frame.
func step(_delta = 0):
	# Calculate the directions of the players.
	player1.determine_direction(player2.global_position)
	player2.determine_direction(player1.global_position)
	
	# Recieve input.
	if rec.is_playing:
		if rec.controlling_p1:
			player1.input.calc_input()
			player2.input.buffer.advance_index()
		else:
			player1.input.buffer.advance_index()
			player2.input.calc_input()
	else:
		player1.input.calc_input()
		player2.input.calc_input()
			
	# Determine the state.
	player1.determine_state()
	player2.determine_state()
	
	# Set the action depending on the state.
	player1.act_state(_delta)
	player2.act_state(_delta)
	
	# Check for damage.
	player1.check_damage_collisions()
	player2.check_damage_collisions()
	
	# Handle animation
	player1.set_animation()
	player2.set_animation()
	
	# TODO - Get rid of this. First we'll need to make our own physics.
	player1.move_and_slide()
	player2.move_and_slide()
	

func _physics_process(_delta):
	if not rec.is_recording:
		if rec.is_playing:
			rec.index += 1
			if rec.index == rec.record_length or Input.is_action_just_pressed("replay_play"):
				rec.pause_recording()
		else:
			if Input.is_action_just_pressed("replay_switch"):
				rec.switch_control()
	
			if Input.is_action_just_pressed("replay_start"):
				rec.record_length = rec.begin_recording()
		
			if Input.is_action_just_pressed("replay_play"):
				rec.play_recording()
	
	else:
		rec.index += 1
		
		if rec.index == rec.record_length or Input.is_action_just_pressed("replay_start"):
			rec.record_length = rec.end_recording()
		
	# ----------------
	
	step(_delta)

