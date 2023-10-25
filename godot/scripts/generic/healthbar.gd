class_name Healthbar extends ProgressBar

@onready var scene = get_node("../../..")
@export var player_number: int
var player: Character

var max_health: int

# Set the max and current health for each character.
func _ready():
	player = Callable(scene, "get_player" + str(player_number)).call()
	max_health = player.MAX_HEALTH
	self.max_value = max_health
	self.value = max_health

# Update the healthbar. 
# This function is triggered upon a character taking damage.
func update():
	# TODO - make it so the character handles if they're dead, and we
	# only handle the displayed value.
	if player.current_health <= 0:
		scene.on_character_death(player)
	
	self.value = player.current_health
