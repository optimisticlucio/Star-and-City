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
