/*
    This is a template/test character for the game, and is not meant to be implemented into the game
    outside of development. When testing using this character, be ABSOLUTELY CERTAIN they are not
    still somehow part of the game when you're ready to push to prod.

    The character's name is Ky Quiche, in case you're wondering. He has no relation to the similarly
    named "Ky Kiske" from Guilty Gear and is legally distinct.
*/

// !! NOTE: A lot of this is WIP because I need to figure out how to connect shit here to the
// !! engine, because I'm a little dumb lol. At least I got the state machine partially built!

pub mod states;

use crate::prelude::character::*;
use crate::prelude::*;

use self::states::*;

#[derive(GodotClass)]
#[class(base=CharacterBody2D)]
pub struct TestCharacter {
    pub speed: i16,
    pub jump_velocity: i16,
    pub sprite: Sprite2D,
    pub state: StateWrapper,
}

#[godot_api]
impl CharacterBody2DVirtual for TestCharacter {
    fn init(_base: Base<CharacterBody2D>) -> Self {
        todo!()
    }
}

#[godot_api]
impl TestCharacter {
    #[func]
    fn determine_state(&self) {
        todo!()
    }
}
