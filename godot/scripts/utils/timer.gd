class_name DTimer

const TICKS_PER_SECOND := 60

var infinite := false # Set to true when you want the timer to not do anything.
var tick_count := TICKS_PER_SECOND # Counts down to 0 from TICKS_PER_SECOND.
var seconds := 1

func _init(sec := 1, inf := false):
	seconds = sec
	infinite = inf

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
