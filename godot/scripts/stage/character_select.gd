extends Node2D

# To not have to search for them constantly
var characters: Array[Node]
var p1_arrow: Pointing_Arrow
var p2_arrow: Pointing_Arrow

class Pointing_Arrow:
	var root: Node
	var characters: Array[Node]
	var node: Node
	var debug_node: Label
	var display_spawn: Node
	var current_preview: Character = null
	var offset: Vector2
	var pointing_at: int
	
	# Yes, this is unsafe and will break if people forget to assign values.
	# However, that's your punishment for being a moron with this function.
	func _init(init_node = null, debug = null, display = null, init_offset = null, init_pointing_at = 0):
		self.node = init_node
		self.root = node.get_tree().root
		self.debug_node = debug
		self.display_spawn = display
		self.offset = init_offset
		self.pointing_at = init_pointing_at
		
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
		new_node.state = Character.State.PREVIEW
		root.add_child.call_deferred(new_node)
		
		current_preview = new_node

# Sets the values for the aformentioned variables.
func set_default_values() -> void:
	var info = get_node("DEBUG INFO")
	characters = get_node("CHARACTER BUTTONS").get_children()
	p1_arrow = Pointing_Arrow.new(get_node("P1_Arrow"), info.get_node("P1char"),
			get_node("p1_preview_spawn"), Vector2(-30, -140))
	p2_arrow = null # TODO

# Called when the node enters the scene tree for the first time.
func _ready():
	set_default_values()
	p1_arrow.move_to(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("gamepad_right"):
		p1_arrow.move_relative(1)
	elif Input.is_action_just_pressed("gamepad_left"):
		p1_arrow.move_relative(-1)

