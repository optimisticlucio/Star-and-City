class_name InputManagerV2 extends Node

# TODO - The current input manager is REALLY WASTEFUL!
# I'm trying to think of how to improve it, but every improvement i can think of 
# either misses inputs or is also wasteful in its own right.

# I considered having each move be a "state machine", that way each frame we just need
# to update a bunch of state machines rather than repeat checks over a buffer, 
# but unless i missed something it's very easy to miss inputs like that.
# Consider - a move's input is 236P. The player inputs 2356P. or 23145236P.
# It's possible the input buffer "gives up" on waiting for 6P right before it actually
# arrives, and misses the new 23.
