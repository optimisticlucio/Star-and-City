pub mod characters;
pub mod prelude;
pub mod generic;

use crate::prelude::*;

use godot::engine::{Sprite2D, Sprite2DVirtual};

// This stuff is from the tutorial, mostly to understand how
// the rust extension even works.
#[derive(GodotClass)]
#[class(base=Sprite2D)]
struct Player {
    speed: f64,
    angular_speed: f64,

    #[base]
    sprite: Base<Sprite2D>,
}

#[godot_api]
impl Sprite2DVirtual for Player {
    fn init(sprite: Base<Sprite2D>) -> Self {
        godot_print!("Hello, world!"); // Prints to the Godot console

        Self {
            speed: 400.0,
            angular_speed: std::f64::consts::PI,
            sprite,
        }
    }

    fn physics_process(&mut self, delta: f64) {
        // GDScript code:
        //
        // rotation += angular_speed * delta
        // var velocity = Vector2.UP.rotated(rotation) * speed
        // position += velocity * delta

        self.sprite.rotate((self.angular_speed * delta) as f32);

        let rotation = self.sprite.get_rotation();
        let velocity = Vector2::UP.rotated(rotation) * self.speed as f32;
        self.sprite.translate(velocity * delta as f32);

        // or verbose:
        // self.sprite.set_position(
        //     self.sprite.get_position() + velocity * delta as f32
        // );
    }
}
//------------------------------------------------------------------
