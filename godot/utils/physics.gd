class_name DPhysics extends Node
# Stands for Deterministic Physics. This is primarily different from Godot's physics
# in that it uses entirely integer arithmetic as opposed to any floats/doubles.
# This allows for calculations to be practically identical across different architectures. 

# -------------- CONSTS --------------

const FLOOR_LOCATION := 600 # The Y of the floor in the rendering engine.
const DEFAULT_GRAVITY := 100

# ------------------------------------

# Represents a point in space that moves.
class ChangingPosition:
	var location: Math.Position
	var velocity: Math.Position
	var acceleration: Math.Position

	func _init(location_x: int = 0, location_y: int = 0):
		location = Math.Position.new(location_x, location_y)
		velocity = Math.Position.new()
		acceleration = Math.Position.new()

	# Change the position based on its current acceleration, velocity, and location.
	func move() -> Math.Position:
		# Change the velocity based on the current acceleration.
		# See your local Calculus 101 class for additional information.
		velocity.x += acceleration.x
		velocity.y += acceleration.y

		# Change location based on current velocity. See above.
		location.x += velocity.x
		location.y += velocity.y

		return location.clone()
	
	# Clones the changing position.
	func clone() -> ChangingPosition:
		var clone := ChangingPosition.new(location.x, location.y)
		clone.velocity = velocity.clone()
		clone.acceleration = acceleration.clone()
		return clone
		
	# Returns the character's supposed next location in space.
	func check_move() -> Math.Position:
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

	# Moves everything around for one frame.
	func step() -> void:
		var from_to := {}
		for element in physics_elements:
			from_to[element] = Math.Line.new(element.position, element.check_move())
		
		var coll = mark_collisions(from_to)

		# TODO - move things to their appropriate location.
	
	# sub-function of step.
	# Goes over the list of 
	func mark_collisions(elements: Dictionary) -> Dictionary:
		# NOTE - This is O(n^2), but at any moment we're only expecting to have like... 2
		# objects in the scene. maybe 4 if they're both shooting a projectile. 
		# A better algorithm is O(nlogn) but takes sorting once per frame which will likely
		# take longer than just doing the stupid calculation a few more times.
		# If this ends up being a dumb idea, here's a better algorithm:
		# https://www.geeksforgeeks.org/given-a-set-of-line-segments-find-if-any-two-segments-intersect/
		for x in elements.keys():
			for y in elements.keys():
				if x != y && elements[x].intersects_with(elements[y]):
					pass # TODO - actually do something here

		return {}
