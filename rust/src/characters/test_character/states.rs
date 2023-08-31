/// The wrapper for the state machine. Necessary to allow for structs to use
/// the state machine as a field.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StateWrapper {
    Idle(Idle),
    WalkLeft(WalkLeft),
    WalkRight(WalkRight),
    Crouch(Crouch),
}

impl Default for StateWrapper {
    fn default() -> Self {
        StateWrapper::Idle(Idle)
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
impl Idle {
    /// Place value in wrapper.
    pub fn wrap(self) -> StateWrapper {
        StateWrapper::Idle(self)
    }

    /// Transition to WalkLeft.
    pub fn to_walk_left(self) -> WalkLeft {
        WalkLeft
    }

    /// Transition to WalkRight.
    pub fn to_walk_right(self) -> WalkRight {
        WalkRight
    }

    /// Transition to Crouch.
    pub fn to_crouch(self) -> Crouch {
        Crouch
    }
}

// Implement states that walk left can transition into.
impl WalkLeft {
    /// Place value in wrapper.
    pub fn wrap(self) -> StateWrapper {
        StateWrapper::WalkLeft(self)
    }

    /// Transition to WalkLeft.
    pub fn to_idle(self) -> Idle {
        Idle
    }

    /// Transition to Crouch.
    pub fn to_crouch(self) -> Crouch {
        Crouch
    }
}

// Implement states that idle can transition into.
impl WalkRight {
    /// Place value in wrapper.
    pub fn wrap(self) -> StateWrapper {
        StateWrapper::WalkRight(self)
    }

    /// Transition to WalkLeft.
    pub fn to_idle(self) -> Idle {
        Idle
    }

    /// Transition to Crouch.
    pub fn to_crouch(self) -> Crouch {
        Crouch
    }
}

// Implement states that crouch can transition into.
impl Crouch {
    /// Place value in wrapper.
    pub fn wrap(self) -> StateWrapper {
        StateWrapper::Crouch(self)
    }

    /// Transition to Idle.
    pub fn to_idle(self) -> Idle {
        Idle
    }
}
