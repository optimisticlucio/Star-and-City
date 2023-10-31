class_name DTimer

const TICKS_PER_SECOND := 60

var infinite := false # Set to true when you want the timer to not do anything.
var tick_count := TICKS_PER_SECOND # Counts down to 0 from TICKS_PER_SECOND.
var reset_seconds := 99
var seconds := 99

func _init(sec := 99, inf := false):
	reset_seconds = sec
	infinite = inf
	reset_clock()

# adds i to the default timer. Returns the new default time.
func add_to_default(i: int) -> int:
	reset_seconds += i
	return reset_seconds

# Adds i to the current timer. Returns the new second count.
func add_to_clock(i: int) -> int:
	seconds += i
	return seconds

func reset_clock():
	seconds = reset_seconds

# Ticks down once, returns the current amount of seconds, and stops ticking at 
# 0 seconds. Returns -1 if time is set to infinite.
func tick() -> int:
	if !infinite:
		if seconds: # if seconds > 0
			tick_count -= 1
			if !tick_count:
				tick_count = TICKS_PER_SECOND
				seconds -= 1
		return seconds
	else:
		return -1
