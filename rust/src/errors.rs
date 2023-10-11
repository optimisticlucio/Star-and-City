use std::result::Result as StdResult;
use thiserror::Error as ErrorTrait;

pub type Result<T> = StdResult<T, Error>;

#[derive(Debug, Clone, ErrorTrait)]
pub enum Error {
    #[error("A quotient attempted to divide by zero")]
    DivideByZero,
}