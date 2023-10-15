extends Node2D

# This is the array holding all the characters. It's set at runtime because fuck you,
# I am not changing this shit every time we add a character and until this is public
# we'll deal with the 0.1ms loss in efficiency.
var char_array: Array[Node] 

# Called when the node enters the scene tree for the first time.
func _ready():
	char_array = get_node("CHARACTER BUTTONS").get_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# TODO - Change where the arrow is pointing on button presses.

# This moves a certain player's arrow towards the specified character.
func move_to_char(char_num: int, player1 := true):
	pass # TODO
