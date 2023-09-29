class_name DPhysics extends Node
# Stands for Deterministic Physics. This is primarily different from Godot's physics
# in that it uses entirely integer arithmetic as opposed to any floats/doubles.
# This allows for calculations to be practically identical across different architectures. 

# -------------- CONSTS --------------

const FLOOR_LOCATION := 600 # The Y of the floor in the rendering engine.

# ------------------------------------

# Represents a singular location in 2D space.
class Position:
	var x: int
	var y: int

	func _init(x: int = 0, y: int = 0):
		self.x = x
		self.y = y
	
	func clone() -> Position:
		return Position.new(x, y)

# Represents a point in space that moves.
class ChangingPosition:
	var location: Position
	var velocity: Position
	var acceleration: Position

	func _init(location_x: int = 0, location_y: int = 0):
		location = Position.new(location_x, location_y)
		velocity = Position.new()
		acceleration = Position.new()

	# Change the position based on its current acceleration, velocity, and location.
	func move() -> Position:
		# Change the velocity based on the current acceleration.
		# See your local Calculus 101 class for additional information.
		velocity.x += acceleration.x
		velocity.y += acceleration.y

		# Change location based on current velocity. See above.
		# QUESTION: Shouldn't this be += velocity?
		location.x = velocity.x
		location.y = velocity.y

		return location.clone()
	
	func clone() -> ChangingPosition:
		var clone := ChangingPosition.new(location.x, location.y)
		clone.velocity = velocity.clone()
		clone.acceleration = acceleration.clone()
		return clone
		
	# Returns the character's supposed next location in space.
	func check_move() -> Position:
		# First, clone the current position.
		var clone := self.clone()
		# Then, perform the move calculation on it to get the next position.
		return clone.move()
	
	# Checks if the position is on the floor.
	func is_on_floor() -> bool:
		return location.y <= FLOOR_LOCATION

# The class that will contain all physics elements in the scene and move them around.
class MatchPhysics:
	var physics_elements: Array[ChangingPosition]

