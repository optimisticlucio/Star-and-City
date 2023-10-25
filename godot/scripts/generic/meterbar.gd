class_name Meterbar extends ProgressBar

@onready var scene = get_node("../../..")

# Set the max and current meter for each character.
func _ready():
	self.max_value = scene.player1.MAX_METER
	self.value = scene.player1.DEFAULT_METER

# Update the meterbar. 
# This function is triggered upon a character gaining or losing meter.
func update():
	# NOTE: See note in `_ready()` on this anti-pattern.
	match name:
		"Meterbar1": self.value = scene.player1.current_meter
		"Meterbar2": self.value = scene.player2.current_meter
