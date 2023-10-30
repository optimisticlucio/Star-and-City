class_name Meterbar extends ProgressBar

@onready var scene = owner.get_parent()
@export var player_number: int
var player: Character

# Set the max and current meter for each character.
func _ready():
	player = Callable(scene, "get_player" + str(player_number)).call()
	self.max_value = player.MAX_METER
	self.value = player.DEFAULT_METER
	
# Update the meterbar. 
# This function is triggered upon a character gaining or losing meter.
func update():
	self.value = player.current_meter

