/* THIS FILE IS PURE PSEUDOCODE
    This file'll handle talking to the godot render engine. We _cannot_ allow it to change
    anything, and I really mean anything, in the matchengine. Only listen.
    Maybe only listen when matchengine says? Checking stuff without prompting may lead to us
    reading unfinished or visually incorrect data.

    We might just write this in GDScript to save on time? We aren't super pressed for efficiency
    in this section. Like it'll be nice but not the end of the world as long as the match
    engine is running on time.
*/