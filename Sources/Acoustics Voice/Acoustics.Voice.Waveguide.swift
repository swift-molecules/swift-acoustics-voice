import Numeric

extension Acoustics.Voice {
    /// The tract stepped as a Kelly–Lochbaum waveguide (Kelly and Lochbaum 1962): equal cylindrical sections, each
    /// crossed in one sample, so the rate is the sections times the speed of sound over the tube's length.
    ///
    /// Waves carry volume flow: in a section of characteristic impedance Z = ρc / A the flow is u = f − b and the
    /// pressure Z(f + b), f travelling to the mouth and b back. Pressure and flow are continuous at a junction, so
    /// with k = (Aᵢ − Aᵢ₊₁) / (Aᵢ + Aᵢ₊₁) the waves leaving it are bᵢ = k fᵢ + (1 + k) bᵢ₊₁ and
    /// fᵢ₊₁ = (1 − k) fᵢ − k bᵢ₊₁. A closed source reflects flow unchanged; the source's own flow U enters as
    /// f = U + b.
    ///
    /// Each section loses the visco-thermal boundary-layer attenuation of a tube of its radius a (Kirchhoff; in
    /// the form of Keefe 1984, J. Acoust. Soc. Am. 75, 58, eq. 13 for large shear numbers),
    /// α = (1 / ac) √(ωμ / 2ρ) (1 + (γ − 1) / √Pr), taken at the tube's lowest closed–open resonance c / 4L.
    struct Waveguide {
        /// Sections, and the rate they are stepped at, per second.
        let count: Int
        let rate: Double
        let density: Double
        let speed: Double
        let ending: Tract.Mouth
        let attenuation: Double
        /// ρc / A of each section.
        var impedance: [Double]
        /// The reflection k of each junction, between section i and i + 1.
        var junction: [Double]
        /// The fraction of a wave left after crossing each section.
        var gain: [Double]
        /// The waves arriving at each section's mouth end, and at its source end.
        var forward: [Double]
        var backward: [Double]
        var nextForward: [Double]
        var nextBackward: [Double]
        var mouth: Mouth

        init(tract: Tract, air: Acoustics.Air, sections: Int, mouth ending: Tract.Mouth) {
            let length = tract.length.underlying
            self.count = sections
            self.speed = air.speed.underlying
            self.density = air.density.underlying
            self.rate = Double(sections) * speed / length
            self.ending = ending
            // γ = 1.4 and Pr = 0.71 for air near room temperature (Keefe 1984, Table I).
            let thermal = 1 + (1.4 - 1) / 0.71.squareRoot()
            let omega = 2 * Double.pi * speed / (4 * length)
            self.attenuation = (omega * air.viscosity.underlying / (2 * density)).squareRoot() * thermal / speed
            self.impedance = []
            self.junction = []
            self.gain = []
            self.forward = [Double](repeating: 0, count: sections)
            self.backward = [Double](repeating: 0, count: sections)
            self.nextForward = forward
            self.nextBackward = backward
            self.mouth = Mouth()
            shape(Self.areas(of: tract, sections: sections))
        }
    }
}

extension Acoustics.Voice.Waveguide {
    /// The state of the mouth's end: its radiation filter, and the flow out of it.
    struct Mouth {
        var flow: Double = 0
        var numerator: (Double, Double) = (0, 0)
        var denominator: (Double, Double) = (1, 0)
        var lastForward: Double = 0
        var lastReflected: Double = 0
    }
}

extension Acoustics.Voice.Waveguide {
    /// The area of each section, in square metres, from the tract's pieces.
    static func areas(of tract: Acoustics.Voice.Tract, sections: Int) -> [Double] {
        let pieces = tract.areas.count
        return (0..<sections).map { i in
            let piece = Swift.min((i * pieces) / sections, pieces - 1)
            return tract.areas[piece].underlying
        }
    }

    /// Sets the section areas, in square metres, keeping the waves already travelling.
    mutating func shape(_ areas: [Double]) {
        let delta = speed / rate
        impedance = areas.map { density * speed / $0 }
        junction = (0..<(count - 1)).map { i in (areas[i] - areas[i + 1]) / (areas[i] + areas[i + 1]) }
        gain = areas.map { area in
            let radius = (area / Double.pi).squareRoot()
            return Double.exp(-attenuation / radius * delta)
        }
        // The baffled piston's R ∥ L, by the bilinear transform s = 2 rate (1 − z⁻¹) / (1 + z⁻¹), as the
        // reflection b / f = (Zr − Z) / (Zr + Z) of the last section's impedance Z.
        let area = areas[count - 1]
        let z = impedance[count - 1]
        let r = 128 * density * speed / (9 * Double.pi * Double.pi * area)
        let l = 8 * density * (area / Double.pi).squareRoot() / (3 * Double.pi * area)
        let k = 2 * rate * l
        mouth.numerator = (k * (r - z) - z * r, -k * (r - z) - z * r)
        mouth.denominator = (k * (r + z) + z * r, -k * (r + z) + z * r)
    }

    /// The pressure at the source end, in pascals, if the source lets the flow `flow` through now.
    func pressure(flow: Double) -> Double {
        impedance[0] * (flow + 2 * backward[0])
    }

    /// One sample, with the source letting `flow` through, in cubic metres per second.
    mutating func step(flow: Double) {
        let last = count - 1
        nextForward[0] = gain[0] * (flow + backward[0])
        for i in 0..<last {
            let k = junction[i]
            let f = forward[i]
            let b = backward[i + 1]
            nextBackward[i] = gain[i] * (k * f + (1 + k) * b)
            nextForward[i + 1] = gain[i + 1] * ((1 - k) * f - k * b)
        }
        let f = forward[last]
        let reflected: Double
        switch ending {
        case .open:
            reflected = -f
        case .radiating:
            reflected =
                (mouth.numerator.0 * f + mouth.numerator.1 * mouth.lastForward - mouth.denominator.1
                    * mouth.lastReflected) / mouth.denominator.0
            mouth.lastForward = f
            mouth.lastReflected = reflected
        }
        nextBackward[last] = gain[last] * reflected
        mouth.flow = f - reflected
        swap(&forward, &nextForward)
        swap(&backward, &nextBackward)
    }
}
