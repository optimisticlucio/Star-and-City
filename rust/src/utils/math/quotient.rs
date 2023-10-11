use crate::prelude::*;

use std::cmp::Ordering;

/// A struct representing a quotient, which is the simplest and most effective way 
/// for us to approximate a float without using any float arithmetic.
#[derive(Clone, Copy, Debug)]
pub struct Quotient {
    #[allow(unused)]
    pub numerator: isize,
    #[allow(unused)]
    pub denominator: isize,
}

impl Quotient {
    #[allow(unused)]
    pub fn new(numerator: isize, denominator: isize) -> Self {
        Quotient { numerator, denominator }
    }

    /// Perform integer division, checking if the denominator is zero.
    #[allow(unused)]
    #[allow(clippy::result_unit_err)]
    pub fn int_divide(&self) -> Result<isize> {
        if self.denominator == 0 {
            return Err(Error::DivideByZero);
        }

        Ok(self.numerator / self.denominator)
    }

    /// Perform integer division. If the denominator is zero, this will panic.
    #[allow(unused)]
    pub fn int_divide_unchecked(&self) -> isize {
        self.numerator / self.denominator
    }

    /// Multiply an integer by the quotient.
    #[allow(unused)]
    pub fn multiply_int(&self, integer: isize) -> isize {
        (self.numerator * integer) / self.denominator
    }
}

/*
    NOTE: The following functions are comparative. These compare two quotients 
      (one self, one other) and return a boolean. To compare a quotient and an integer, simply create
      a new quotient with the integer as the dividend and 1 as the divisor.
    NOTE: These comparisons work because multiplying both quotients by the divisor
      of the other results in two quotients with the same divisor but equal ratios to their starting
      quotients. Since both divisors are always equal after this, we can ignore them, and now just
      compare the dividends - which are just integers. This algorithm also strips the sign of the
      other's quotient's divisor and multiplies the result by its own divisor, thus preserving the
      sign of the fraction and returning accurate results. 
*/

impl PartialEq for Quotient {
    fn eq(&self, other: &Self) -> bool {
        self.numerator * other.denominator.abs() * self.denominator.signum() == other.numerator * self.denominator.abs() * other.denominator.signum()
    }
}

impl Eq for Quotient {}

impl PartialOrd for Quotient {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        (self.numerator * other.denominator.abs() * self.denominator.signum()).partial_cmp(&(other.numerator * self.denominator.abs() * other.denominator.signum()))
    }
}

impl Ord for Quotient {
    fn cmp(&self, other: &Self) -> Ordering {
        self.partial_cmp(other).unwrap() // Ints are well-ordered so I believe this is always `Some()`.
    }
}