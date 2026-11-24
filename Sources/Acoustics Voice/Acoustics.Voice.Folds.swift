public import Acoustics

extension Acoustics.Voice {
    /// Vocal folds as two masses on springs, one below the other, after Ishizaka and Flanagan (1972, Bell Syst.
    /// Tech. J. 51, 1233) in the symmetric form of Steinecke and Herzel (1995, J. Acoust. Soc. Am. 97, 1874).
    ///
    /// Each fold's lower and upper segment moves across the airway, x from rest; the glottis between the two folds is
    /// aᵢ = aᵢ₀ + 2l xᵢ. Each part obeys mᵢẍᵢ + rᵢẋᵢ + kᵢxᵢ + k_c(xᵢ − xⱼ) = Fᵢ, with a contact spring 3kᵢ and
    /// a damping ratio greater by one while it touches the other fold. The air through the narrowest opening drives
    /// it: the lower part feels Pₛ − ρU²/2a₁² over l d₁, the upper part the pressure above the glottis over l d₂.
    /// The flow U meets the tract's pressure at its input (Titze 2008, J. Acoust. Soc. Am. 123, 2733).
    ///
    /// The tension Q of Ishizaka and Flanagan sets the pitch: it multiplies every stiffness and divides every mass,
    /// so the folds' own frequencies are proportional to it.
    public struct Folds: Hashable, Sendable {
        public var lower: Acoustics.Voice.Segment
        public var upper: Acoustics.Voice.Segment
        /// The spring between the lower and the upper part.
        public var coupling: Stiffness.Value<Double>
        /// The length of the folds along the airway's width.
        public var length: Measure<1, Space.Physical>.Value<Double>

        public init(
            lower: Acoustics.Voice.Segment,
            upper: Acoustics.Voice.Segment,
            coupling: Stiffness.Value<Double>,
            length: Measure<1, Space.Physical>.Value<Double>
        ) {
            self.lower = lower
            self.upper = upper
            self.coupling = coupling
            self.length = length
        }
    }
}

extension Acoustics.Voice.Folds {
    /// The standard symmetric folds of Steinecke and Herzel (1995, §II and Table I), the adult human values of
    /// Ishizaka and Flanagan (1972): m₁ = 0.125 g, m₂ = 0.025 g, k₁ = 80 N/m, k₂ = 8 N/m, k_c = 25 N/m, ζ = 0.1,
    /// l = 1.4 cm, d₁ = 2.5 mm, d₂ = 0.5 mm, and a rest area of 0.05 cm² at both parts.
    public static var human: Self {
        Self(
            lower: Acoustics.Voice.Segment(
                mass: Mass.kilograms(0.125e-3),
                stiffness: Stiffness.amount(80),
                loss: Loss.amount(0.2),
                thickness: Space.Physical.metres(2.5e-3),
                rest: Area<Space.Physical>.amount(0.05e-4)
            ),
            upper: Acoustics.Voice.Segment(
                mass: Mass.kilograms(0.025e-3),
                stiffness: Stiffness.amount(8),
                loss: Loss.amount(0.2),
                thickness: Space.Physical.metres(0.5e-3),
                rest: Area<Space.Physical>.amount(0.05e-4)
            ),
            coupling: Stiffness.amount(25),
            length: Space.Physical.metres(1.4e-2)
        )
    }

    /// These folds made larger by `factor` in every length, of the same tissue under the same stress: masses grow
    /// with its cube, stiffnesses with it (a stress over an area across a length), and areas with its square, so
    /// their own frequencies fall as one over it.
    public func scaled(by factor: Double) -> Self {
        func segment(_ part: Acoustics.Voice.Segment) -> Acoustics.Voice.Segment {
            Acoustics.Voice.Segment(
                mass: part.mass * (factor * factor * factor),
                stiffness: part.stiffness * factor,
                loss: part.loss,
                thickness: part.thickness * factor,
                rest: part.rest * (factor * factor)
            )
        }
        return Self(lower: segment(lower), upper: segment(upper), coupling: coupling * factor, length: length * factor)
    }
}
