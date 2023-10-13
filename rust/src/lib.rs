pub mod characters;
pub mod errors;
pub mod generic;
pub mod prelude;
pub mod utils;

use godot::prelude::{gdextension, ExtensionLibrary};

// Declare the extension trait, which allows for Godot's bindings to work.
pub struct MyExtension;

// Implement it.
#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}
