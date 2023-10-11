use super::quotient::Quotient;

/// Represents a singular location in 2D space.
#[derive(Debug, Default, PartialEq, Eq, Hash, PartialOrd, Ord, Clone, Copy)]
pub struct Point {
    #[allow(unused)]
    pub x: isize,
    #[allow(unused)]
    pub y: isize,
}

impl Point {
    #[allow(unused)]
    pub fn new(x: isize, y: isize) -> Self {
        Point { x, y }
    }
}

impl From<(isize, isize)> for Point {
    fn from(tup: (isize, isize)) -> Self {
        Point { x: tup.0, y: tup.1 }
    }
}

impl From<Point> for (isize, isize) {
    fn from(pos: Point) -> Self {
        (pos.x, pos.y)
    }
}

/// The oritentation of two triangles in relation to one another.
/// See [here](https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/#) for more information.
#[derive(Debug, PartialEq, Eq, Hash, PartialOrd, Ord, Clone, Copy)]
pub enum TriangleRelationship {
    Clockwise,
    Counterclockwise,
    Collinear,
}

/// A line in 2D space, denoted by two points.
#[derive(Debug, Default, PartialEq, Eq, Hash, PartialOrd, Ord, Clone, Copy)]
pub struct Line {
    pub point_1: Point,
    pub point_2: Point,
}

impl Line {
    #[allow(unused)]
    pub fn new(point_1: Point, point_2: Point) -> Self {
        Self { point_1, point_2 }
    }

    /// Checks whether two lines intersect.
    #[allow(unused)]
    pub fn intersects_with(&self, other: &Line) -> bool {
        let o1 = Self::triangle_orientation(self.point_1, self.point_2, other.point_1);
        let o2 = Self::triangle_orientation(self.point_1, self.point_2, other.point_2);
        let o3 = Self::triangle_orientation(other.point_1, other.point_2, self.point_1);
        let o4 = Self::triangle_orientation(other.point_1, other.point_2, self.point_2);

        // TODO: There are some special cases here, but I am too lazy to program the whole check. Fix this later.
        todo!();

        ((o1 != o2) && (o3 != o4))
    }

    /// Check for the orientation of two intersecting lines based on the angles their intersection
    /// produces. For more information see [here](https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/#).
    #[allow(unused)]
    pub fn triangle_orientation(p1: Point, p2: Point, p3: Point) -> TriangleRelationship {
        let angle_1 = Quotient::new(p2.y - p1.y, p2.x - p1.x);
        let angle_2 = Quotient::new(p3.y - p2.y, p3.x - p2.x);

        match angle_1.cmp(&angle_2) {
            std::cmp::Ordering::Less => TriangleRelationship::Counterclockwise,
            std::cmp::Ordering::Equal => TriangleRelationship::Collinear,
            std::cmp::Ordering::Greater => TriangleRelationship::Clockwise,
        }
    }
}
