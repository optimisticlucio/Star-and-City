class_name health_bar extends ProgressBar

@onready var scene = get_node("..")

# Set the max and current health for each character.
func _ready():
	var max_health: int
		
	# NOTE: Probably not the most idiomatic way to achieve this.
	# At some point, probably worth looking into an alternative.
	match name:
		"Healthbar1": max_health = scene.player1.MAX_HEALTH
		"Healthbar2": max_health = scene.player2.MAX_HEALTH
	
	self.max_value = max_health
	self.value = max_health
