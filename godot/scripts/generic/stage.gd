class_name Stage extends Node2D

# The current active characters
var player1: PlayerInfo
var player2: PlayerInfo

const DEFAULT_LIVES := 1

class PlayerInfo:
	var character: Character
	var lives: int
	var healthbar: Node # These may be pointless, but
	var meter: Node #  writing them in for certainty.
	
	func _init(init_char: Character):
		character = init_char
		lives = DEFAULT_LIVES
	
	func set_healthbar(node: Node):
		healthbar = node
	
	func set_meter(node: Node):
		meter = node
	
	func get_character():
		return character
	
	# Adds i to the life count. Returns the new life count.
	func modify_lives(i: int) -> int:
		lives += i
		return lives
	
	# Records a death (reduces life and such).
	# If character has no more lives, returns false.
	func record_death() -> bool:
		return (bool)(modify_lives(-1) > 0)

# For recording purposes
var rec: Recording

# Count down.
var timer_node: Label
var timer: DTimer

func _init():
	# BEFORE EVERYTHING, we need the characters loaded in.
	player1 = PlayerInfo.new(summon_character(Global.p1_char.character,
		Vector2(-100,0),
		InputHandler.Direction.RIGHT,
		InputHandler.MappedInput.default(),
		Character.SkinVariant.DEFAULT))
	
	player2 = PlayerInfo.new(summon_character(Global.p2_char.character,
		Vector2(100,0),
		InputHandler.Direction.LEFT,
		null,
		Character.SkinVariant.DEFAULT))

func _ready():
	rec = Recording.new(player1.get_character(), player2.get_character())
	# Oh jesus there's gotta be a better way to do this shit.
	timer_node = get_node("./camera_and_UI/UI_node/Control/MarginContainer/VBoxContainer/HBoxContainer/Time")
	timer = DTimer.new(99)
	
	move_child(player1.get_character(), -1)
	move_child(player2.get_character(), -1)

func get_player1() -> Character:
	return player1.get_character()

func get_player2() -> Character:
	return player2.get_character()

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
	var p1 = player1.get_character()
	var p2 = player2.get_character()
	# Calculate the directions of the players.
	p1.determine_direction(p2.global_position)
	p2.determine_direction(p1.global_position)
	
	# Recieve input.
	# TODO - clean this shit up.
	if rec.is_playing:
		if rec.controlling_p1:
			p1.input.calc_input()
			p2.input.buffer.advance_index()
		else:
			p1.input.buffer.advance_index()
			p2.input.calc_input()
	else:
		p1.input.calc_input()
		p2.input.calc_input()
			
	# Determine the state.
	p1.determine_state()
	p2.determine_state()
	
	# Set the action depending on the state.
	p1.act_state(_delta)
	p2.act_state(_delta)
	
	# Check for damage.
	p1.check_damage_collisions()
	p2.check_damage_collisions()
	
	# Ok, body count, who's dead?
	handle_death(p1.current_health > 0, p2.current_health > 0)
	
	# Handle animation
	p1.set_animation()
	p2.set_animation()

	# Update timer.
	count_tick()
	
	# TODO - Get rid of this. First we'll need to make our own physics.
	p1.move_and_slide()
	p2.move_and_slide()
	

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

func handle_death(p1_alive: bool, p2_alive: bool):
	if !p1_alive or !p2_alive:
		# TODO - both dead edge case.
		if !p1_alive:
			kill_character(player1)
		else:
			kill_character(player2)
		
	
func kill_character(player):
	print("Oh no! %s has died!" % player.get_character().name)
	# If the character still has more lives, reset. If not, end game.
	if player.record_death():
		pass
	else:
		get_tree().pause()
	
