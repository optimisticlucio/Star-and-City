class_name Stage extends Node2D

# The current active characters
var player1: Character
var player2: Character

# For recording purposes
var rec: Recording

# Count down.
var timer_node: Label
var timer: DTimer

func _init():
	# BEFORE EVERYTHING, we need the characters loaded in.
	player1 = summon_character(Global.p1_char.character,
		Vector2(-100,0),
		InputHandler.Direction.RIGHT,
		InputHandler.MappedInput.default(),
		Character.SkinVariant.DEFAULT)
	
	player2 = summon_character(Global.p2_char.character,
		Vector2(100,0),
		InputHandler.Direction.LEFT,
		null,
		Character.SkinVariant.DEFAULT)

func _ready():
	rec = Recording.new(player1, player2)
	timer_node = get_node("./camera_and_UI/UI_node/Time")
	timer = DTimer.new(99)
	move_child(player1, -1)
	move_child(player2, -1)

func get_player1() -> Character:
	return player1

func get_player2() -> Character:
	return player2

# Summon a character to the stage. 
func summon_character(
	character: PackedScene,
	location := Vector2(400,500),
	direction := InputHandler.Direction.RIGHT,
	map: InputHandler.MappedInput = null,
	skin := Character.SkinVariant.DEFAULT
) -> Character:
	var player: Character = character.instantiate()
	player._init(location, map, skin, direction)
	add_child(player)

	return player

# The series of actions taken every virtual frame.
func step(_delta = 0):
	# Calculate the directions of the players.
	player1.determine_direction(player2.global_position)
	player2.determine_direction(player1.global_position)
	
	# Recieve input.
	# TODO - clean this shit up.
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

	# Update timer.
	count_tick()
	
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

# Ticks down once, sends values to clock node.
func count_tick() -> void:
	var time = timer.tick()
	timer_node.set_text(str(time))

# Signal is triggered when a single character dies.
func on_character_death(character):
	# TEMP
	print("Oh no! %s has died!" % character.name)
	get_tree().paused = true
