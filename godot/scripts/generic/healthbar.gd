class_name Healthbar extends ProgressBar

@onready var scene = get_node("../../..")

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

signal single_character_death(character: Character)
signal both_character_deaths()

# Update the healthbar. 
# This function is triggered upon a character taking damage.
func update():
	var player1_health = scene.player1.current_health
	var player2_health = scene.player2.current_health
	
	# Check if both or either player is dead.
	# TODO: Have only one healthbar emit these signals instead of both.
	if not player1_health > 0 and not player2_health > 0:
		both_character_deaths.emit()
	elif player1_health > 0 and not player2_health > 0:
		single_character_death.emit(scene.player2)
	elif player2_health > 0 and not player1_health > 0:
		single_character_death.emit(scene.player1)
	
	# NOTE: See note in `_ready()` on this anti-pattern.
	match name:
		"Healthbar1": self.value = player1_health
		"Healthbar2": self.value = player2_health
