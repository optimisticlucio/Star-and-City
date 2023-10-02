class_name Math

# Represents any rational number through a dividend and divisor.
class Quotient:
	var dividend: int
	var divisor: int
	
	# NOTE: `floor()` is necessary in integer division despite being useless
	# in this context to shut the GDScript compiler up.
	
	# Create a new quotient.
	func _init(top: int, bottom: int):
		dividend = top
		divisor = bottom
	
	# Duplicate the quotient.
	func duplicate() -> Quotient:
		return Quotient.new(dividend, divisor)
		
	# Divide the dividend by the divisor and return an `int`.
	func int_divide() -> int:
		return dividend/floor(divisor)

	# Divide the dividend by the divisor and return a `float`.
	func float_divide() -> float:
		return float(dividend)/divisor
	
	# Multiply a number by the quotient and return an `int`.
	func multiply(multiplicative: int) -> int:
		return (multiplicative * dividend)/floor(divisor)

	#-- In Rust, these are 100% turning into operators. --
	func eq(other: Quotient) -> bool:
		return false # TODO
	
	func gt(other: Quotient) -> bool:
		return false # TODO
	#-----------------------------------------------------


# Represents a singular location in 2D space.
class Position:
	var x: int
	var y: int

	func _init(x: int = 0, y: int = 0):
		self.x = x
		self.y = y
	
	func clone() -> Position:
		return Position.new(x, y)

# Represents a line in 2D space.
class Line:
	var p1: Position
	var p2: Position

	func _init(p1 := Position.new(), p2 := Position.new()):
		self.p1 = p1
		self.p2 = p2
	
	func intersects_with(other: Line) -> bool:
		var o1 = triangle_orientation(p1, p2, other.p1)
		var o2 = triangle_orientation(p1, p2, other.p2)
		var o3 = triangle_orientation(other.p1, other.p2, p1)
		var o4 = triangle_orientation(other.p1, other.p2, p2)	

		# TODO - there are some special cases here, but I am too lazy to 
		# program the whole check. Fix this later.

		return ((o1 != o2) && (o3 != o4))
	
	# sub-function of intersects_with.
	# returns 0 - clockwise, 1 - counterclockwise, 2 - collinear
	func triangle_orientation(p1: Position, p2: Position, p3: Position) -> int:
		var s1 = Quotient.new(p2.y - p1.y, p2.x - p1.x)
		var s2 = Quotient.new(p3.y - p2.y, p3.x - p2.x)

		if s1.eq(s2):
			return 2
		
		if s1.gt(s2):
			return 0
		
		return 1

