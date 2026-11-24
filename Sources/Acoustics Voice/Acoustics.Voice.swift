public import Acoustics
import Numeric

extension Acoustics {
    /// A voice: air from the lungs or air sacs driven through a source that opens and closes, into a vocal tract
    /// that shapes it, making one call.
    ///
    /// The source is vocal folds (`Folds`) for a mammal and the syringeal labia (`Syrinx`) for a bird. Both are
    /// opened by the air they let through and close by their own elasticity, and both feel the pressure the tract
    /// sends back. The tract is a tube of varying area (`Tract`), stepped as a Kelly–Lochbaum waveguide.
    public struct Voice: Hashable, Sendable {
        public var tract: Tract
        public var source: Source
        public var call: Call

        public init(tract: Tract, source: Source, call: Call) {
            self.tract = tract
            self.source = source
            self.call = call
        }
    }
}

extension Acoustics.Voice {
    /// The call as heard at `distance` in front of the mouth, in pascals, `rate` samples a second.
    ///
    /// The tract is stepped at the rate its sections set, at least twice `rate`, the source with it; the mouth
    /// radiates as a simple source, p = (ρ / 4πr) dU/dt (Flanagan 1972, §3.2), and the result is taken to `rate`
    /// through a windowed-sinc low-pass at 0.45 `rate`. The call is followed by 50 ms for the tract to fall quiet.
    public func render(
        rate: Frequency.Value<Double>,
        air: Acoustics.Air = .room,
        distance: Measure<1, Space.Physical>.Value<Double> = Space.Physical.metres(1)
    ) -> [Pressure.Value<Double>] {
        let output = rate.underlying
        let length = tract.length.underlying
        let minimum = Swift.max(32, Int((2 * output * length / air.speed.underlying).rounded(.up)))
        let sections = tract.sections(atLeast: minimum)
        var guide = Waveguide(tract: self.tract, air: air, sections: sections, mouth: .radiating)
        let inner = guide.rate
        let interval = 1 / inner
        let total = Int(((call.duration.underlying + 0.05) * inner).rounded(.up))
        var areas = Waveguide.areas(of: tract, sections: sections)
        let mouthStart = sections - sections / Swift.max(tract.areas.count, 1)
        let scale = air.density.underlying / (4 * Double.pi * distance.underlying) * inner
        var oscillator = Oscillator()
        var radiated = [Double](repeating: 0, count: total)
        var previous = 0.0
        var mouth = -1.0
        for t in radiated.indices {
            let state = call.state(at: Double(t) * interval)
            if t % 16 == 0, state.mouth != mouth, state.mouth > 0 {
                mouth = state.mouth
                areas.replaceSubrange(mouthStart..., with: repeatElement(mouth, count: sections - mouthStart))
                guide.shape(areas)
            }
            let flow = oscillator.step(
                source,
                pressure: state.pressure,
                tension: state.tension,
                guide: guide,
                interval: interval
            )
            guide.step(flow: flow)
            radiated[t] = scale * (guide.radiation.flow - previous)
            previous = guide.radiation.flow
        }
        return Self.resample(radiated, from: inner, to: output).map { Pressure.pascals($0) }
    }

    /// Band-limited resampling: each output sample is the input weighted by a sinc at 0.45 of the lower rate,
    /// under a Blackman window 24 output samples either side.
    static func resample(_ input: [Double], from source: Double, to target: Double) -> [Double] {
        let cutoff = 0.45 * Swift.min(source, target)
        let half = 24 / target
        let count = Int((Double(input.count) * target / source).rounded(.down))
        return (0..<count).map { m in
            let time = Double(m) / target
            let first = Swift.max(0, Int(((time - half) * source).rounded(.up)))
            let last = Swift.min(input.endIndex - 1, Int(((time + half) * source).rounded(.down)))
            guard first <= last else { return 0 }
            var sum = 0.0
            for n in input[first...last].indices {
                let offset = time - Double(n) / source
                let phase = 2 * Double.pi * cutoff * offset
                let sinc = offset == 0 ? 2 * cutoff : Double.sin(phase) / (Double.pi * offset)
                let w = 0.5 + 0.5 * offset / half
                let window = 0.42 - 0.5 * Double.cos(2 * Double.pi * w) + 0.08 * Double.cos(4 * Double.pi * w)
                sum += input[n] * sinc * window
            }
            return sum / source
        }
    }
}
