use godot::prelude::*;
use godot::engine::Sprite2D;
use godot::engine::Sprite2DVirtual;

// Not sure what the next few lines do, but they're required.
struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}
// ----------------------------------------------------------

// This stuff is from the tutorial, mostly to understand how
// the rust extension even works.
#[derive(GodotClass)]
#[class(base=Sprite2D)]
struct Player {
    speed: f64,
    angular_speed: f64,

    #[base]
    sprite: Base<Sprite2D>
}


#[godot_api]
impl Sprite2DVirtual for Player {
    fn init(sprite: Base<Sprite2D>) -> Self {
        godot_print!("Hello, world!"); // Prints to the Godot console
        
        Self {
            speed: 400.0,
            angular_speed: std::f64::consts::PI,
            sprite
        }
    }
}
//------------------------------------------------------------------