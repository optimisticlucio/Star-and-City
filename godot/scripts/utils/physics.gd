class_name DPhysics extends Node
# Stands for Deterministic Physics. This is primarily different from Godot's physics
# in that it uses entirely integer arithmetic as opposed to any floats/doubles.
# This allows for calculations to be practically identical across different architectures. 

# -------------- CONSTS --------------

const FLOOR_LOCATION := 600 # The Y of the floor in the rendering engine.
const DEFAULT_GRAVITY := 100

# ------------------------------------

# Represents a rectangle in space that moves.
class MovingRectangle:
	var rect: Math.Rectangle
	var velocity: Math.Position
	var acceleration: Math.Position
	var associated_node: Node # TODO - Actually implement. Do at home!

	func _init(rect_width: int, rect_height: int, rect_pos:= Math.Position.new(0,0)):
		rect = Math.Rectangle.new(rect_width, rect_height, rect_pos)
		velocity = Math.Position.new()
		acceleration = Math.Position.new()

	# Change the position based on its current acceleration, velocity, and location.
	func move() -> Math.Rectangle:
		# Change the velocity based on the current acceleration.
		# See your local Calculus 101 class for additional information.
		velocity.add(acceleration)

		# Change location based on current velocity. See above.
		rect.pos.add(velocity)

		return rect.clone()
	
	# Clones the changing position. UNASSOCIATES NODE.
	func clone() -> MovingRectangle:
		var rect_clone := MovingRectangle.new(rect.width, rect.height, rect.pos)
		rect_clone.velocity = velocity.clone()
		rect_clone.acceleration = acceleration.clone()
		return rect_clone
		
	# Returns the character's supposed next location in space.
	func check_move() -> Math.Rectangle:
		# First, clone the current position.
		var rect_clone := self.clone()
		# Then, perform the move calculation on it to get the next position.
		return rect_clone.move()
	
	# Updates the associated node to be in the same location as this simulated one.
	func update_node():
		pass # TODO
	
	# Checks if the rectangle is on the floor.
	func is_on_floor() -> bool:
		# TODO - Handle falling on top of someone.
		return rect.pos.y <= FLOOR_LOCATION


# The class that will contain all physics elements in the scene and move them around.
class MatchPhysics:
	# The assumption is that everything in the scene that needs to be collided is, 
	# broadly speaking, representable by non-rotating rectangles.
	var scene_objects: Array[MovingRectangle]

	# Moves all objects in the scene.
	func step():
		virtual_step()
		for x in scene_objects:
			x.update_node()

	# Moves all simulated objects in the scene and performs collision detections.
	func virtual_step():
		# For the sake of later collision detection being O(n), sort the scene array based on x.
		scene_objects.sort_custom(func(a,b): return (a.get_x() < b.get_x()))

		# Move all objects to where they should be.
		for x in scene_objects:
			x.move()
		
		# Now clean up collisions.
		for i in (scene_objects.size() - 1):
			handle_collision(scene_objects[i], scene_objects[i+1])


	# Given two rectangles: checks for collision. If no collision, returns.
	# If collision, moves them both to be next to eachother rather than inside
	# eachother.
	func handle_collision(rect1: MovingRectangle, rect2: MovingRectangle):
		if !rect1.collide(rect2):
			return
		# Thanks to sorting the array, we can just do this handling directly.
		handle_collision_x(rect1.rect, rect2.rect)
		# However, as we have no assumptions on y, we need to order it according to who's higher up.
		var rects := [rect1, rect2]
		var condition := rect1.rect.get_y() <= rect2.rect.get_y()
		
		handle_collision_y(rects[int(!condition)], rects[int(condition)])
		
	# Sub-function. Assumes rect1.x < rect2.x.
	func handle_collision_x(rect1: Math.Rectangle, rect2: Math.Rectangle):
		@warning_ignore("integer_division")
		var impact_point = (rect1.get_end_x() + rect2.get_x())/2
		rect2.set_x(impact_point)
		rect1.set_x(impact_point - rect1.pos.width)
	
	# Sub-function. Assumes rect1.y < rect2.y.
	func handle_collision_y(rect1: Math.Rectangle, rect2: Math.Rectangle):
		@warning_ignore("integer_division")
		var impact_point = (rect1.get_end_y() + rect2.get_y())/2
		rect2.set_y(impact_point)
		rect1.set_y(impact_point - rect1.pos.height)

