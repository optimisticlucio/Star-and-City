// Use the Godot prelude implicitly across the crate.
pub use godot::prelude::*;

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
