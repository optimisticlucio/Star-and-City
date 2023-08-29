class_name health_bar extends ProgressBar

@onready var scene = get_node("..")

func _ready():
	self.max_value = scene.player1.MAX_HEALTH
	self.value = scene.player1.MAX_HEALTH
