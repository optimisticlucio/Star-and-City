extends Node2D

# To not have to search for them constantly
var characters: Array[Node]
var p1_arrow: Pointing_Arrow
var p2_arrow: Pointing_Arrow

class Pointing_Arrow:
	var characters: Array[Node]
	var node: Node
	var debug_node: Label
	var offset: Vector2
	var pointing_at: int
	
	# Yes, this is unsafe and will break if people forget to assign values.
	# However, that's your punishment for being a moron with this function.
	func _init(node = null, debug = null, offset = null, pointing_at = 0):
		self.node = node
		debug_node = debug
		self.offset = offset
		self.pointing_at = pointing_at
		
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
	
	# moves to the character i positions away from the current one.
	func move_relative(i: int):
		move_to((pointing_at + i) % characters.size())


# Sets the values for the aformentioned variables.
func set_default_values() -> void:
	var info = get_node("DEBUG INFO")
	characters = get_node("CHARACTER BUTTONS").get_children()
	p1_arrow = Pointing_Arrow.new(get_node("P1_Arrow"), info.get_node("P1char"), Vector2(-30, -140))
	p2_arrow = null # TODO

# Called when the node enters the scene tree for the first time.
func _ready():
	set_default_values()
	p1_arrow.move_to(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("gamepad_right"):
		p1_arrow.move_relative(1)
	elif Input.is_action_just_pressed("gamepad_left"):
		p1_arrow.move_relative(-1)

