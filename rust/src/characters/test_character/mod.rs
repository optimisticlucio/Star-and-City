/*
    This is a template/test character for the game, and is not meant to be implemented into the game
    outside of development. When testing using this character, be ABSOLUTELY CERTAIN they are not
    still somehow part of the game when you're ready to push to prod.
*/

pub mod states;

use crate::prelude::character::*;
use crate::prelude::*;

use crate::generic::character::Character;

use self::states::*;

/// Our test character, for testing. Do not include in poduction code.
#[derive(GodotClass)]
#[class(base=CharacterBody2D)]
pub struct TestCharacter {
    pub current_health: u32,
    pub current_air_actions: u8,
    pub current_damage_tolerance: [u8; 2],
    pub state: StateWrapper,
    #[base]
    pub base_character: Character,
}

#[godot_api]
impl CharacterBody2DVirtual for TestCharacter {
    fn init(base: Base<CharacterBody2D>) -> Self {
        Self {
            current_health: 100_000,
            current_air_actions: 1,
            current_damage_tolerance: [8, 8],

            state: StateWrapper::Idle(Idle),
            base_character: Character {
                speed: 300,
                jump_velocity: -400,
                air_actions: 1,
                max_health: 100_000,
                defense_value: [3, 4],
                damage_tolerance_default: [8, 8],
                base,
            },
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
