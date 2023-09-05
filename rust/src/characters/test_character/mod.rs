/*
    This is a template/test character for the game, and is not meant to be implemented into the game
    outside of development. When testing using this character, be ABSOLUTELY CERTAIN they are not
    still somehow part of the game when you're ready to push to prod.

    The character's name is Ky Quiche, in case you're wondering. He has no relation to the similarly
    named "Ky Kiske" from Guilty Gear and is legally distinct.
*/

pub mod states;

use crate::prelude::character::*;
use crate::prelude::*;

use self::states::*;

#[derive(GodotClass)]
#[class(base=CharacterBody2D)]
pub struct TestCharacter {
    pub speed: i16,
    pub jump_velocity: i16,
    pub state: StateWrapper,
    #[base]
    pub base: Base<CharacterBody2D>,
}

#[godot_api]
impl CharacterBody2DVirtual for TestCharacter {
    fn init(base: Base<CharacterBody2D>) -> Self {
        godot_print!("SUCCESS!");

        Self {
            speed: 300,
            jump_velocity: -400,
            state: StateWrapper::Idle(Idle),
            base,
        }
    }
}

#[godot_api]
impl TestCharacter {
    #[func]
    fn determine_state(&self) {
        todo!()
    }
}
