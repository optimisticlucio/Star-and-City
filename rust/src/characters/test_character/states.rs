use crate::prelude::*;

/// The wrapper for the state machine. Necessary to allow for structs to use
/// the state machine as a field.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StateWrapper {
    Idle(CharacterState<Idle>),
    WalkLeft(CharacterState<WalkLeft>),
    WalkRight(CharacterState<WalkRight>),
    Crouch(CharacterState<Crouch>),
}

/// The character's state, represented by `T`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct CharacterState<T> {
    __state: PhantomData<T>,
}

impl<T: Default> CharacterState<T> {
    pub fn new() -> CharacterState<T> {
        CharacterState::default()
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct Idle;
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct WalkLeft;
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct WalkRight;
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct Crouch;

// Implement states that idle can transition into.
impl CharacterState<Idle> {
    /// Place value in wrapper.
    pub fn wrap(self) -> StateWrapper {
        StateWrapper::Idle(self)
    }

    /// Transition to WalkLeft.
    pub fn to_walk_left(self) -> CharacterState<WalkLeft> {
        CharacterState::new()
    }

    /// Transition to WalkRight.
    pub fn to_walk_right(self) -> CharacterState<WalkRight> {
        CharacterState::new()
    }

    /// Transition to Crouch.
    pub fn to_crouch(self) -> CharacterState<Crouch> {
        CharacterState::new()
    }
}

// Implement states that walk left can transition into.
impl CharacterState<WalkLeft> {
    /// Place value in wrapper.
    pub fn wrap(self) -> StateWrapper {
        StateWrapper::WalkLeft(self)
    }

    /// Transition to WalkLeft.
    pub fn to_idle(self) -> CharacterState<Idle> {
        CharacterState::new()
    }

    /// Transition to Crouch.
    pub fn to_crouch(self) -> CharacterState<Crouch> {
        CharacterState::new()
    }
}

// Implement states that idle can transition into.
impl CharacterState<WalkRight> {
    /// Place value in wrapper.
    pub fn wrap(self) -> StateWrapper {
        StateWrapper::WalkRight(self)
    }

    /// Transition to WalkLeft.
    pub fn to_idle(self) -> CharacterState<Idle> {
        CharacterState::new()
    }

    /// Transition to Crouch.
    pub fn to_crouch(self) -> CharacterState<Crouch> {
        CharacterState::new()
    }
}

// Implement states that crouch can transition into.
impl CharacterState<Crouch> {
    /// Place value in wrapper.
    pub fn wrap(self) -> StateWrapper {
        StateWrapper::Crouch(self)
    }

    /// Transition to Idle.
    pub fn to_idle(self) -> CharacterState<Idle> {
        CharacterState::new()
    }
}
