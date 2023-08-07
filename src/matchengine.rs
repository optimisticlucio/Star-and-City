/* The following section is entirely pseudocode because I
    didn't check the godot nor rust docs in a while but I wanna 
    get some stuff done rather than procrastinate all day.

// NOTE - NOTHING in this section can rely on anything that is either
// non-deterministic (if I see a float here I will burn down your house)
// or outside of this section (except player input). If we do either,
// the chance of this working online goes down the goddamn toilet.
// Probably also any chance of debugging. Let's try to avoid that.

enum virtual_input {
    Represents the buttons the game expects a player to press,
    like "left", "right", "dust", "slash", etc. Ignores macros.
}

fn action_taken_every_virtual_frame() { 
    // NOTE - Virtual frames should be independent from actual
    // game frames. Hard-set to 60 virtual frames per second.
    // Except maybe cutscenes. We'll get to it when we get to it.
    // By extension, this function should take less than 16mls
    // at the absolute worst.
    // Optimially, less than 1.6mls so rollback can work.

    for player in current_match { 
        // NOTE - we could just hardcode to do this twice to 
        // optimize the time this function takes. 
        // Could be async for each player? Maybe make 
        // "update player status" its own function that we 
        // run twice? Deal with later.

        virtual_input = read_player_input(player_configuration) 
        action_taken = input_buffer(virtual_input)
        take_action(action_taken)
    }
    update_states()
    renderengine.update_visuals()
}

fn read_player_input(config) {
    // This function will take the actual configuration our player
    // has for their button setup (macros included) and convert it
    // to a "virtual input", mapping every button pressed to the
    // equivalent virtual button. Helps avoiding weird-ass button
    // bugs and support netcode.
    // Config is a translation table, to be clear.

    for every button being pressed rn {
        if button is in config: 
            virtual_inputs[config[button]] = true
    }

    return virtual_inputs
}

fn input_buffer(virtual_input) {
    // This is probably going to be a mess to implement. Here's a link:
    https://andrea-jens.medium.com/i-wanna-make-a-fighting-game-a-practical-guide-for-beginners-part-6-311c51ab21c4
    // Input buffer translates what the player is pressing to what action
    // they are trying to do. Ignores current player state, only reads the
    // current action and lines it up with previous actions to see what the
    // player is trying to input. Is it a 5H? 6H? 426H? SDH? All of these
    // options can come from a "forward heavy" being pressed on the final
    // frame, so we need to figure out which it is.

    // To begin, we'll probably just like... do "if it's forward go forward."
    // However we need this function so that when we eventually do implement
    // an input buffer it's not a nightmare to rewrite.


    // TODO, HOLY SHIT.
}

fn take_action(action, player) {
    // This does not take into account whether the move hits, misses, or anything
    // of the sort. All it does is see what the player wants to do, check if it's
    // physically possible and doesn't cancel out of a diff move/break boundaries,
    // and then do it.

    if player.state is not inactive: // NOTE - inactive can be a LOT of things. Go over it later.
        initialize the action the player wants to do.
    
    continue the action currently being taken.
} 

fn update_states() {
    // Now that the players took their actions, let's see what actually
    // happened. Check hitboxes, hurtboxes, character state, update hp, you get the idea.

    // TODO
}

fn renderengine.update_visuals() {
    // This action CAN be async! Yay!
    // Send what needs to be updated to the rendering engine. We can probably
    // get away with only sending what needs to be updated rather than the 
    // entire game state (maybe just flag what needs changing?) to save up
    // on render time.

    // This probably belongs to a diff function so not writing how it works here.
}


    */ 