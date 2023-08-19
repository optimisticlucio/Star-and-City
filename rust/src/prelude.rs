// Use the Godot prelude implicitly across the crate.
pub(crate) use godot::prelude::*;

// Declare the extension trait, which allows for Godot's bindings to work.
pub(crate) struct MyExtension;

// Implement it.
#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}

pub use std::marker::PhantomData;

pub mod character {
    pub use godot::engine::{CharacterBody2D, CharacterBody2DVirtual, Sprite2D};
    pub use godot::obj::Base;
}
