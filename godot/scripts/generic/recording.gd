class_name Recording extends Node

var player1: Character
var player2: Character

var controlling_p1 := true
var is_recording := false
var is_playing := false
var index := 0
var record_length := 1
var buffer := InputHandler.InputBuffer.new()

func _init(p1 = null, p2 = null):
	player1 = p1
	player2 = p2

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
	
	index = 0
	
	print("Beginning recording.")
	
	return rec_length

# Stops a currently running recording. Returns the end-index of the recording.
func end_recording() -> int:
	is_recording = false
	
	var end_index = index
	index = 0
	
	if controlling_p1:
		buffer = player1.input.buffer
		player1.input.buffer = InputHandler.InputBuffer.new()
	else:
		buffer = player2.input.buffer
		player2.input.buffer = InputHandler.InputBuffer.new()
	
	buffer.index = 0
	
	print("Ending recording.")
	
	return end_index

# Plays the recording.
func play_recording():
	is_playing = true
	
	if controlling_p1:
		player2.input.buffer = buffer
	else:
		player1.input.buffer = buffer
	
	index = 0
	
	print("Playing recording.")

# Pauses the recording.
func pause_recording():
	is_playing = false
	
	if controlling_p1:
		player2.input.buffer = InputHandler.InputBuffer.new()
	else:
		player1.input.buffer = InputHandler.InputBuffer.new()
		
	buffer.index = 0
	# TODO - Doing a deep copy of the buffer would be better. But I am lazy.
	print("Pause recording.")
