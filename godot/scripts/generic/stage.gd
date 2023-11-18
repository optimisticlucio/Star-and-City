class_name Stage extends Node2D

@onready var ui = get_node("fight_UI")

const DEFAULT_TIME := 99
const DEFAULT_LIVES := 2

var default_spawn1 := Vector2(300,500)
var default_spawn2 := Vector2(800,500)

# The current active characters
var player1: PlayerInfo
var player2: PlayerInfo

# For recording purposes
var rec: Recording

# Count down.
var timer_node: Label
var timer: DTimer

# Current match state.
var state: MatchState

# Current round
var round_number := 0

enum MatchState {
	PAUSED,
	IDLE,
	COMBAT,
	EGO_SELECTION
}


class PlayerInfo:
	var character: Character
	var lives: int
	var life_node: Node
	var healthbar: Node # These may be pointless, but
	var meter: Node #  writing them in for certainty.
	
	func _init(init_char: Character):
		character = init_char
		lives = DEFAULT_LIVES
	
	func set_healthbar(node: Node):
		healthbar = node
	
	func set_meter(node: Node):
		meter = node
	
	func set_life_node(node: Node):
		life_node = node
		life_node.text = str(lives)
	
	func get_character() -> Character:
		return character
	
	# Adds i to the life count. Returns the new life count.
	func modify_lives(i: int) -> int:
		lives += i
		return lives
	
	# Records a death (reduces life and such).
	# If character has no more lives, returns false.
	func record_death() -> bool:
		life_node.text = str(modify_lives(-1))
		return (bool)(lives > 0)

func _init():
	# BEFORE EVERYTHING, we need the characters loaded in.
	player1 = PlayerInfo.new(summon_character(Global.p1_char.character,
		default_spawn1,
		InputHandler.Direction.RIGHT,
		InputHandler.MappedInput.default(),
		Character.SkinVariant.DEFAULT))
	
	player2 = PlayerInfo.new(summon_character(Global.p2_char.character,
		default_spawn2,
		InputHandler.Direction.LEFT,
		null,
		Character.SkinVariant.DEFAULT))
	
	state = MatchState.COMBAT

func _ready():
	rec = Recording.new(player1.get_character(), player2.get_character())
	timer_node = ui.get_timer()
	timer = DTimer.new(99)
	player1.set_life_node(ui.get_p1_lives())
	player2.set_life_node(ui.get_p2_lives())
	
	player1.character.other_player = get_player2()
	player2.character.other_player = get_player1()
	move_child(player1.get_character(), -1)
	move_child(player2.get_character(), -1)
	
	reset_round()

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
	if state == MatchState.PAUSED:
		return

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
	
	match state:
		MatchState.COMBAT:
			act_state_combat()
		
		MatchState.IDLE:
			act_state_anim()
		
		MatchState.EGO_SELECTION:
			pass # TODO

	# Update timer.
	count_tick()
	
	move_camera()

# The portion of act_state which is only relevant to active fighting.
func act_state_combat():
	# Determine the state.
	p1.determine_state()
	p2.determine_state()
	
	# Set the action depending on the state.
	p1.act_state(_delta)
	p2.act_state(_delta)

	act_state_anim()
	
	# Check for damage.
	p1.check_damage_collisions()
	p2.check_damage_collisions()
	
	# Ok, body count, who's dead?
	handle_death(p1.current_health > 0, p2.current_health > 0)

# The portion of act_state which is relevant to animations.
func act_state_anim():
	# Handle animation
	p1.set_animation()
	p2.set_animation()

	# TODO - Replace rid of this. First we'll need to make our own physics.
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
		

# Resets elements to their round start position.
func reset_round():
	round_number += 1
	
	player1.get_character().reset_round_values()
	player2.get_character().reset_round_values()
	player1.get_character().position = default_spawn1
	player2.get_character().position = default_spawn2
	
	
	if round_number == 2 or round_number == 3:
		state = MatchState.EGO_SELECTION
	
	timer.reset_clock()
	

# Moves camera towards the center between both characters
func move_camera():
	# Move to be in the middle of both players.
	var pos1 = player1.get_character().position
	var pos2 = player2.get_character().position
	ui.get_camera().set_position(Vector2(pos1.x + pos2.x, pos1.y + pos2.y) * 0.5)
	
	# Zoom to keep both players in. Roughly.
	var min_distance = 300
	var max_distance = 700
	var distance = abs(pos1.x - pos2.x)
	# Let's make sure zoom is between min and max.
	var zoom_percentage = min(max(distance, min_distance), max_distance)
	# Now - what ratio is it between min and max?
	zoom_percentage = (zoom_percentage - min_distance) / float(max_distance)
	# Inverse (the smaller the distance, the more we zoom.
	zoom_percentage = 1 - zoom_percentage
	# Now let's see how much to zoom.
	zoom_percentage = (0.6 + zoom_percentage)
	ui.get_camera().zoom = Vector2(zoom_percentage, zoom_percentage)

func kill_character(player):
	print("Oh no! %s has died!" % player.get_character().name)
	# If the character still has more lives, reset. If not, end game.
	if player.record_death():
		reset_round()
	else:
		get_tree().paused = true

# Adds the given ego to the given character.
func add_ego(player: Character, ego: EGOGifts.Gift):
	var node_to_update: Node
	if player == player1.get_character():
		node_to_update = get_node("fight_UI").get_p1_ego()
	else:
		node_to_update = get_node("fight_UI").get_p2_ego()
	
	node_to_update.text += EGOGifts.Gift.keys()[ego] + " "
	

# Gives both players a choice between randomly selected EGO.
func ego_selection():
	# for now just give both a random EGO
	player1.get_character().equip_ego_gift(EGOGifts.EGO_POOL[randi() % EGOGifts.EGO_POOL.size()])
	player2.get_character().equip_ego_gift(EGOGifts.EGO_POOL[randi() % EGOGifts.EGO_POOL.size()])
	state = MatchState.COMBAT
