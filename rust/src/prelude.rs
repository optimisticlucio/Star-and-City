// Use the Godot prelude implicitly across the crate.
pub use godot::prelude::*;

// Declare the extension trait, which allows for Godot's bindings to work.
pub struct MyExtension;

// Implement it.
#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}

pub use crate::errors::{Error, Result};

pub mod math {
    pub use crate::utils::math::{
        geometry::{Line, Point},
        quotient::Quotient,
    };
    
}

pub mod character {
    pub use godot::engine::{CharacterBody2D, CharacterBody2DVirtual, Sprite2D};
    pub use godot::obj::Base;
}
