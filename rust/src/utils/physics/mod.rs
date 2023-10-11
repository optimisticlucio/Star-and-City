use std::collections::BTreeSet;

use crate::prelude::math::*;

// We are reimplementing the physics engine using only integers to prevent issues with
// different architectures computing floats and other types differently.

#[allow(unused)]
const FLOOR_LOCATION: isize = 600;
#[allow(unused)]
const DEFAULT_GRAVITY: isize = 100;

/// Represents a point in space that is moving or is capable of moving.
#[derive(Debug, Default, PartialEq, Eq, PartialOrd, Ord, Clone, Copy, Hash)]
pub struct ChangingPosition {
    pub location: Point,
    pub velocity: Point,
    pub acceleration: Point,
}

impl ChangingPosition {
    pub fn new(initial_x: isize, initial_y: isize) -> Self {
        ChangingPosition {
            location: Point::new(initial_x, initial_y),
            velocity: Point::default(),
            acceleration: Point::default()
        }
    }

    /// Change the position based on its current acceleration, velocity, and location.
    // NOTE: Because "move" is a keyword, this function's name needs to be escaped with `r#`.
    pub fn r#move(&mut self) -> Point {
        // NOTE: Should this take place before or after the velocity is applied to the next position?
        self.velocity.x += self.acceleration.x;
        self.velocity.y += self.acceleration.y;

        self.location.x += self.velocity.x;
        self.location.y += self.velocity.y;

        self.location
    }

    /// Return the next supposed location in space.
    pub fn check_move(&self) -> Point {
        Point {
            // NOTE: See above note in `r#move()`.
            x: self.location.x + self.velocity.x + self.acceleration.x,
            y: self.location.y + self.velocity.y + self.velocity.y,
        }
    }

    /// Checks if a position is on (or under) the floor.
    pub fn is_on_floor(&self) -> bool {
        self.location.y <= FLOOR_LOCATION
    }
}

/// The struct that will contain all physics elements in the scene and move them around.
#[derive(Debug, Default, PartialEq, Eq, PartialOrd, Ord, Hash, Clone)]
pub struct MatchPhysics {
    pub physics_elements: Vec<ChangingPosition>,
}

impl MatchPhysics {
    pub fn step(self) {
        let mut changing_elements = BTreeSet::<Line>::new();
        
        for element in &self.physics_elements {
            changing_elements.insert(Line::new(element.location, element.check_move()));
        }

        #[allow(unused)]
        let coll = self.mark_collisions(changing_elements);

        // TODO: move things to their appropriate location.
        todo!()
    }

    pub fn mark_collisions(&self, elements: BTreeSet::<Line>) -> BTreeSet<Line> {
        // NOTE - This is O(n^2), because I was a moron. We're probably gonna need 4 points per character, 
		// so that's at least 8 calculations per frame not including projectiles.
		// Move to this algorithm later:
		// https://www.geeksforgeeks.org/given-a-set-of-line-segments-find-if-any-two-segments-intersect/
        for x in &elements {
            for y in &elements {
                if x != y && x.intersects_with(y) {
                    // TODO: Actually put the logic here later.
                    todo!()
                }
            }
        }

        // TEMP
        BTreeSet::new()
    }
}