extends Node2D

# To not have to search for them constantly
var characters: Array[Node]
var p1_arrow: PointingArrow
var p2_arrow: PointingArrow
var current_arrow: PointingArrow
var p1_is_picking := true

class PointingArrow:
	var root: Node
	var characters: Array[Node]
	var node: Node
	var debug_node: Label
	var display_spawn: Node
	var current_preview: Character = null
	var offset: Vector2
	var pointing_at: int
	var direction: InputHandler.Direction
	
	# Yes, this is unsafe and will break if people forget to assign values.
	# However, that's your punishment for being a moron with this function.
	func _init(init_node = null, debug = null, display = null, init_offset = null,
			init_pointing_at = 0, character_dir := InputHandler.Direction.RIGHT):
		self.node = init_node
		self.root = node.get_parent()
		self.debug_node = debug
		self.display_spawn = display
		self.offset = init_offset
		self.pointing_at = init_pointing_at
		self.direction = character_dir
		
		# This is the array holding all the characters. It's set at runtime because fuck you,
		# I am not changing this shit every time we add a character and until this is public
		# we'll deal with the 0.1ms loss in efficiency.
		characters = node.get_node("../CHARACTER BUTTONS").get_children()

	
	# There is an assumption that arr_num < char_num. See the above comment
	# for why I chose to not enforce it.
	func move_to(arr_num: int):
		pointing_at = arr_num
		
		node.position = characters[arr_num].position + offset
		debug_node.text = characters[arr_num].get_meta("Name")
		
		change_visual()
	
	# moves to the character i positions away from the current one.
	func move_relative(i: int):
		move_to((pointing_at + i) % characters.size())
	
	# Changes the display_node to show the correct character.
	func change_visual():
		if current_preview != null:
			current_preview.free()
		print(characters[pointing_at].get_meta("char_node"))
		var new_node: Character = characters[pointing_at].get_meta("char_node").instantiate()
		new_node.position = display_spawn.position
		new_node.change_direction(direction) 
		new_node.state = Character.State.PREVIEW
		root.add_child.call_deferred(new_node)
		
		current_preview = new_node
	
	# Returns the currently selected character.
	func chosen():
		return characters[pointing_at].get_meta("char_node")

# Sets the values for the aformentioned variables.
func set_default_values() -> void:
	var info = get_node("DEBUG INFO")
	characters = get_node("CHARACTER BUTTONS").get_children()
	p1_arrow = PointingArrow.new(get_node("P1_Arrow"), info.get_node("P1char"),
			get_node("p1_preview_spawn"), Vector2(-40, -140), 0, InputHandler.Direction.RIGHT)
	p2_arrow = PointingArrow.new(get_node("P2_Arrow"), info.get_node("P2char"),
			get_node("p2_preview_spawn"), Vector2(0, -140), 0, InputHandler.Direction.LEFT)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_default_values()
	p2_arrow.node.hide()
	p1_arrow.move_to(0)
	current_arrow = p1_arrow


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("gamepad_right"):
		current_arrow.move_relative(1)
	elif Input.is_action_just_pressed("gamepad_left"):
		current_arrow.move_relative(-1)
	elif Input.is_action_just_pressed("gamepad_A"):
		if p1_is_picking:
			p1_is_picking = false
			Global.p1_char.character = p1_arrow.chosen()
			p2_arrow.move_to(0)
			p2_arrow.node.show()
			current_arrow = p2_arrow
		else:
			Global.p2_char.character = p2_arrow.chosen()
			get_tree().change_scene_to_file("res://scenes/stage/floor_of_general_works.tscn")
			

