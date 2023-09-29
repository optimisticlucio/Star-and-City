class_name DPhysics extends Node
# Stands for Deterministic Physics

#--------------CONSTS--------------

const FLOOR_LOCATION := 600 # The Y of the floor in the rendering engine.

# Represents a singular location in 2D space.
class Position:
    var x: int
    var y: int

    func _init(x:= 0, y:= 0) -> Position:
        self.x = x
        self.y = y
    
    func clone() -> Position:
        return Position.new(x, y)

# Represents a point in space that moves.
class ChangingPosition:
    var location: Position
    var velocity: Position
    var acceleration: Position

    func _init(location_x:= 0, location_y:= 0) -> ChangingPosition:
        location = Position.new(location_x, location_y)
        velocity = Position.new()
        acceleration = Position.new()
    
    func move() -> Position:
        # NOTE - GDScript does not support operator overloading.
        # Please change this to look less janky when we move to rust.

        # velocity += acceleration
        velocity.x += acceleration.x 
        velocity.y += acceleration.y 

        # location += velocity
        location.x = velocity.x 
        location.y = velocity.y 

        return location.clone()
    
    func clone() -> ChangingPosition:
        var clone = ChangingPosition.new(location.x, location.y)
        clone.velocity = velocity.clone()
        clone.acceleration = acceleration.clone()
        return clone

