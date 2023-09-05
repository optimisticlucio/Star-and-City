use crate::prelude::*;
use crate::prelude::character::*;

/// A character in the game. Should be "inherited" by individual characters.
#[derive(GodotClass)]
#[class(base=CharacterBody2D)]
pub struct Character {
    /// The character's speed.
    pub speed: i64,
    /// The character's jumping velocity.
    pub jump_velocity: i16,
    /// The amount of actions a player can take in the air 
    /// (such as jumping again) before being unable to continue.
    pub air_actions: u8,
    /// The character's maximum health.
    pub max_health: u32,
    /// The character's defense. This is multiplied against any incoming damage. 
    /// A quotient =1 is baseline, <1 is less damage taken, and >1 is more damage taken.
    pub defense_value: [u8; 2],
    /// The character's default tolerance to incoming damage. 
    /// The defense tolerance changes due to various circumstances in the game, such as
    /// being in the middle of a combo. Incoming damage is multiplied against this value.
    pub damage_tolerance_default: [u8; 2], 

    #[base]
    pub base: Base<CharacterBody2D>,
}