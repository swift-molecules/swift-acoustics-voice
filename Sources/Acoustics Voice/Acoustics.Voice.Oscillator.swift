extension Acoustics.Voice {
    /// The moving state of a source: for folds, the lower and upper part's displacement and velocity; for the
    /// syrinx, the labium's in the first pair. Stepped by semi-implicit Euler at the waveguide's rate.
    struct Oscillator {
        var lower: (x: Double, v: Double) = (0, 0)
        var upper: (x: Double, v: Double) = (0, 0)
    }
}

extension Acoustics.Voice.Oscillator {
    /// The flow U through an opening of area `area` from the pressure `pressure` below it into the waveguide:
    /// Pₛ − p = ρU|U| / 2a², with p = Z(U + 2b) the pressure the waveguide answers with. Solved as
    /// U = 2D / (Z + √(Z² + 2ρ|D| / a²)), D = Pₛ − 2Zb.
    static func flow(area: Double, pressure: Double, guide: Acoustics.Voice.Waveguide) -> Double {
        let z = guide.impedance[0]
        let drive = pressure - 2 * z * guide.backward[0]
        let kinetic = guide.density / (2 * area * area)
        return 2 * drive / (z + (z * z + 4 * kinetic * Swift.abs(drive)).squareRoot())
    }

    /// One step of the source at the pressure `pressure` below it and the tension `tension`; returns the flow it
    /// lets into the waveguide now.
    mutating func step(
        _ source: Acoustics.Voice.Source,
        pressure: Double,
        tension: Double,
        guide: Acoustics.Voice.Waveguide,
        interval: Double
    ) -> Double {
        switch source {
        case .folds(let folds):
            return step(folds, pressure: pressure, tension: tension, guide: guide, interval: interval)
        case .syrinx(let syrinx):
            return step(syrinx, pressure: pressure, tension: tension, guide: guide, interval: interval)
        }
    }

    private mutating func step(
        _ folds: Acoustics.Voice.Folds,
        pressure: Double,
        tension q: Double,
        guide: Acoustics.Voice.Waveguide,
        interval dt: Double
    ) -> Double {
        let l = folds.length.underlying
        let m1 = folds.lower.mass.underlying / q
        let m2 = folds.upper.mass.underlying / q
        let k1 = folds.lower.stiffness.underlying * q
        let k2 = folds.upper.stiffness.underlying * q
        let kc = folds.coupling.underlying * q
        let a1 = folds.lower.rest.underlying + 2 * l * lower.x
        let a2 = folds.upper.rest.underlying + 2 * l * upper.x
        let narrowest = Swift.min(a1, a2)
        var u = 0.0
        var f1 = 0.0
        var f2 = 0.0
        if narrowest > 0 {
            u = Self.flow(area: narrowest, pressure: pressure, guide: guide)
            let above = guide.pressure(flow: u)
            let inside = u >= 0 ? pressure : above
            f1 = l * folds.lower.thickness.underlying * (inside - guide.density * u * u / (2 * a1 * a1))
            f2 = l * folds.upper.thickness.underlying * above
        } else if a1 > 0 {
            f1 = l * folds.lower.thickness.underlying * pressure
        }
        let critical1 = (m1 * k1).squareRoot()
        let critical2 = (m2 * k2).squareRoot()
        var r1 = folds.lower.loss.underlying * critical1
        var r2 = folds.upper.loss.underlying * critical2
        if a1 <= 0 {
            f1 -= 3 * k1 * a1 / (2 * l)
            r1 += 2 * critical1
        }
        if a2 <= 0 {
            f2 -= 3 * k2 * a2 / (2 * l)
            r2 += 2 * critical2
        }
        let acceleration1 = (f1 - r1 * lower.v - k1 * lower.x - kc * (lower.x - upper.x)) / m1
        let acceleration2 = (f2 - r2 * upper.v - k2 * upper.x - kc * (upper.x - lower.x)) / m2
        lower.v += acceleration1 * dt
        upper.v += acceleration2 * dt
        lower.x += lower.v * dt
        upper.x += upper.v * dt
        return u
    }

    private mutating func step(
        _ syrinx: Acoustics.Voice.Syrinx,
        pressure: Double,
        tension q: Double,
        guide: Acoustics.Voice.Waveguide,
        interval dt: Double
    ) -> Double {
        let l = syrinx.length.underlying
        let m = syrinx.mass.underlying / q
        let k = syrinx.stiffness.underlying * q
        let tau = syrinx.delay.underlying
        let a1 = syrinx.entry.underlying + 2 * l * (lower.x + tau * lower.v)
        let a2 = syrinx.exit.underlying + 2 * l * (lower.x - tau * lower.v)
        let narrowest = Swift.min(a1, a2)
        var u = 0.0
        var mean = 0.0
        if narrowest > 0 {
            u = Self.flow(area: narrowest, pressure: pressure, guide: guide)
            let above = guide.pressure(flow: u)
            mean = above + (pressure - above) * (1 - a2 / a1)
        } else if a1 > 0 {
            mean = pressure
        }
        var force = l * syrinx.thickness.underlying * mean
        let critical = (m * k).squareRoot()
        var r = syrinx.loss.underlying * critical
        if narrowest <= 0 {
            force -= 3 * k * narrowest / (2 * l)
            r += 2 * critical
        }
        let x = lower.x
        let acceleration = (force - r * lower.v - syrinx.saturation * x * x * lower.v - k * x) / m
        lower.v += acceleration * dt
        lower.x += lower.v * dt
        return u
    }
}
