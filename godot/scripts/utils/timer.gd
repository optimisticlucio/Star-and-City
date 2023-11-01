class_name DTimer

const TICKS_PER_SECOND := 60

var tick_count := 0
var reset_seconds := 99
var seconds := 99

func _init(sec := 99):
	reset_seconds = sec
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

# Advances the timer by one tick, and advanced by one second every X
# ticks, where X is the TICKS_PER_SECOND.
func tick() -> int:
	tick_count += 1
	seconds -= int((tick_count % TICKS_PER_SECOND) == 0)
	return seconds
