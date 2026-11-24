public import Acoustics

extension Acoustics.Voice {
    /// The syrinx: two labia that close the bronchus, set vibrating by the air through them as a bird calls.
    ///
    /// Each labium is one mass whose surface carries a wave upward, after Titze (1988, J. Acoust. Soc. Am. 83, 1536)
    /// as applied to the syrinx by Laje, Gardner and Mindlin (2002, Phys. Rev. E 65, 051921): the openings at its
    /// entry and exit are a₁ = a₁₀ + 2l(x + τẋ) and a₂ = a₂₀ + 2l(x − τẋ), τ the time the wave takes to cross half
    /// the labium. The mean pressure between the labia, P_e + (Pₛ − P_e)(1 − a₂/a₁) with P_e the pressure above,
    /// pushes on the face l T: m ẍ + r ẋ + c x² ẋ + k x = l T P̄, the cubic damping c keeping the swing bounded. The
    /// labia close on a contact spring 3k. The flow meets the tract's pressure at its input, as for `Folds`.
    ///
    /// The tension Q sets the pitch: it multiplies the stiffness and divides the mass.
    public struct Syrinx: Hashable, Sendable {
        public var mass: Mass.Value<Double>
        public var stiffness: Stiffness.Value<Double>
        /// The loss factor of its linear damping, η = 2ζ.
        public var loss: Loss.Value<Double>
        /// The cubic damping c, in newton seconds per cubic metre: no atom holds its kind yet.
        public var saturation: Double
        /// The length of the labia across the airway.
        public var length: Measure<1, Space.Physical>.Value<Double>
        /// The labia's depth along the airflow.
        public var thickness: Measure<1, Space.Physical>.Value<Double>
        /// The openings at the entry and the exit at rest.
        public var entry: Area<Space.Physical>.Value<Double>
        public var exit: Area<Space.Physical>.Value<Double>
        /// The time the surface wave takes to cross half the labium.
        public var delay: Time.Duration.Value<Double>

        public init(
            mass: Mass.Value<Double>,
            stiffness: Stiffness.Value<Double>,
            loss: Loss.Value<Double>,
            saturation: Double,
            length: Measure<1, Space.Physical>.Value<Double>,
            thickness: Measure<1, Space.Physical>.Value<Double>,
            entry: Area<Space.Physical>.Value<Double>,
            exit: Area<Space.Physical>.Value<Double>,
            delay: Time.Duration.Value<Double>
        ) {
            self.mass = mass
            self.stiffness = stiffness
            self.loss = loss
            self.saturation = saturation
            self.length = length
            self.thickness = thickness
            self.entry = entry
            self.exit = exit
            self.delay = delay
        }
    }
}
