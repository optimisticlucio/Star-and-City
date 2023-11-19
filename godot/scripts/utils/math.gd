class_name Math

# Represents any rational number through a dividend and divisor.
class Quotient:
	var dividend: int
	var divisor: int
	
	# Create a new quotient.
	func _init(top: int, bottom: int):
		dividend = top
		divisor = bottom
	
	# Duplicate the quotient.
	func duplicate() -> Quotient:
		return Quotient.new(dividend, divisor)
		
	# Divide the dividend by the divisor and return an `int`.
	func int_divide() -> int:
		@warning_ignore("integer_division")
		return dividend/divisor

	# Divide the dividend by the divisor and return a `float`.
	func float_divide() -> float:
		return float(dividend)/divisor
	
	# Multiply a number by the quotient and return an `int`.
	func multiply(multiplicative: int) -> int:
		@warning_ignore("integer_division")
		return (multiplicative * dividend)/divisor
	
	# NOTE: The following functions are comparative. These compare
	#  two quotients (one self, one other) and return a boolean.
	#  To compare a quotient and an integer, simply create a new quotient
	#  with the integer as the dividend and 1 as the divisor.
	# NOTE: These comparisons work because multiplying both quotients by the divisor
	#  of the other results in two quotients with the same divisor but equal ratios to their
	#  starting quotients. Since both divisors are always equal after this, we can ignore them,
	#  and now just compare the dividends - which are just integers.
	#  This algorithm also strips the sign of the other's quotient's divisor and multiplies the result by
	#  its own divisor, thus preserving the sign of the fraction and returning accurate results.
	
	# Checks if another quotient is equal to this one.
	func eq(other: Quotient) -> bool:
		return self.dividend * abs(other.divisor) * sign(self.divisor) == other.dividend * abs(self.divisor) * sign(other.divisor)
	
	# Checks if another quotient is greater than this one.
	func gt(other: Quotient) -> bool:
		return self.dividend * abs(other.divisor) * sign(self.divisor) > other.dividend * abs(self.divisor) * sign(other.divisor)
	
	# Checks if another quotient is greater than or equal to this one.
	func gte(other: Quotient) -> bool:
		return self.dividend * abs(other.divisor) * sign(self.divisor) >= other.dividend * abs(self.divisor) * sign(other.divisor)
	
	# Checks if another quotient is less than this one.
	func lt(other: Quotient) -> bool:
		return self.dividend * abs(other.divisor) * sign(self.divisor) < other.dividend * abs(self.divisor) * sign(other.divisor)

	# Checks if another quotient is less than or equal to this one.
	func lte(other: Quotient) -> bool:
		return self.dividend * abs(other.divisor) * sign(self.divisor) <= other.dividend * abs(self.divisor) * sign(other.divisor)

# Represents a singular location in 2D space.
class Position:
	var x: int
	var y: int

	func _init(init_x: int = 0, init_y: int = 0):
		self.x = init_x
		self.y = init_y
	
	func add(other_pos: Position):
		x += other_pos.x
		y += other_pos.y
	
	func clone() -> Position:
		return Position.new(x, y)

# Represents the relationship between two triangles.
enum TriangleRelationship {CLOCKWISE, COUNTERCLOCKWISE, COLLINEAR}

# Represents a line in 2D space.
class Line:
	var p1: Position
	var p2: Position

	func _init(init_p1 := Position.new(), init_p2 := Position.new()):
		self.p1 = init_p1
		self.p2 = init_p2
	
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
	func triangle_orientation(pos1: Position, pos2: Position, pos3: Position) -> TriangleRelationship:
		var s1 = Quotient.new(pos2.y - pos1.y, pos2.x - pos1.x)
		var s2 = Quotient.new(pos3.y - pos2.y, pos3.x - pos2.x)

		if s1.eq(s2):
			return TriangleRelationship.COLLINEAR
		
		if s1.gt(s2):
			return TriangleRelationship.CLOCKWISE
		
		return TriangleRelationship.COUNTERCLOCKWISE
	
# Represents a non-rotateable rectangle in 2D space.
class Rectangle:
	var pos: Position
	var width: int
	var height: int

	func _init(init_width: int, init_height: int, init_pos := Position.new(0,0)):
		width = init_width
		height = init_height
		pos = init_pos
	
	func clone() -> Rectangle:
		return Rectangle.new(width, height, pos.clone())
	
	func get_x() -> int:
		return pos.x
	
	func set_x(x: int):
		pos.x = x
	
	func get_end_x() -> int:
		return pos.x + width

	func get_end_y() -> int:
		return pos.y + height
	
	func get_y() -> int:
		return pos.y
	
	func set_y(y: int):
		pos.y = y
	
	func get_pos() -> Position:
		return pos

	# Returns whether the two rectangles currently collide.
	func collide(other: Rectangle) -> bool:
		return (self.get_x() < other.get_end_x() &&
				self.get_end_x() > other.get_x() &&
				self.get_y() < other.get_end_y() &&
				self.get_end_y() > other.get_y())
