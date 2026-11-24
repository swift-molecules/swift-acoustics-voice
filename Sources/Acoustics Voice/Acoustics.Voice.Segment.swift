public import Acoustics

extension Acoustics.Voice {
    /// One segment of a vocal fold in the two-mass model, its lower or its upper part.
    public struct Segment: Hashable, Sendable {
        public var mass: Mass.Value<Double>
        public var stiffness: Stiffness.Value<Double>
        /// Its loss factor while apart, η = 2ζ for the damping ratio ζ.
        public var loss: Loss.Value<Double>
        /// Its depth along the airflow.
        public var thickness: Measure<1, Space.Physical>.Value<Double>
        /// The glottis's area at this part when the folds are at rest.
        public var rest: Area<Space.Physical>.Value<Double>

        public init(
            mass: Mass.Value<Double>,
            stiffness: Stiffness.Value<Double>,
            loss: Loss.Value<Double>,
            thickness: Measure<1, Space.Physical>.Value<Double>,
            rest: Area<Space.Physical>.Value<Double>
        ) {
            self.mass = mass
            self.stiffness = stiffness
            self.loss = loss
            self.thickness = thickness
            self.rest = rest
        }
    }
}
