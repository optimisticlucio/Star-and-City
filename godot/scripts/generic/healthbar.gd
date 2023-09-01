class_name health_bar extends ProgressBar

@onready var scene = get_node("..")

var max_health: int

# Set the max and current health for each character.
func _ready():
	# NOTE: Probably not the most idiomatic way to achieve this.
	# At some point, probably worth looking into an alternative.
	match name:
		"Healthbar1": max_health = scene.player1.MAX_HEALTH
		"Healthbar2": max_health = scene.player2.MAX_HEALTH
	
	self.max_value = max_health
	self.value = max_health

func update():
	# NOTE: See above note.
	match name:
		"Healthbar1": self.value = scene.player1.current_health
		"Healthbar2": self.value = scene.player2.current_health
