public import Acoustics

extension Acoustics.Voice {
    /// A vocal tract: a tube from the source to the mouth, given as the cross-sectional areas of equally long
    /// pieces, the first at the source and the last at the mouth.
    ///
    /// It is stepped as a Kelly–Lochbaum waveguide (Kelly and Lochbaum 1962, Proc. 4th Int. Congr. Acoust., G42):
    /// cylindrical sections, each one sample long at a rate the tube's length sets, joined by scattering junctions.
    public struct Tract: Hashable, Sendable {
        /// From the source to the mouth.
        public var length: Measure<1, Space.Physical>.Value<Double>
        /// The areas of equally long pieces, from the source to the mouth.
        public var areas: [Area<Space.Physical>.Value<Double>]

        public init(length: Measure<1, Space.Physical>.Value<Double>, areas: [Area<Space.Physical>.Value<Double>]) {
            self.length = length
            self.areas = areas
        }
    }
}

extension Acoustics.Voice.Tract {
    /// A tube of one area throughout.
    public static func uniform(
        length: Measure<1, Space.Physical>.Value<Double>,
        area: Area<Space.Physical>.Value<Double>
    ) -> Self {
        Self(length: length, areas: [area])
    }
}

extension Acoustics.Voice.Tract {
    /// The resonances of the tube driven by flow at a closed source: the peaks of the flow out of the mouth over
    /// the flow in, ascending, from the waveguide's impulse response.
    public func formants(
        count: Int,
        air: Acoustics.Air = .room,
        mouth: Mouth = .radiating
    ) -> [Frequency.Value<Double>] {
        var guide = Acoustics.Voice.Waveguide(tract: self, air: air, sections: sections(atLeast: 64), mouth: mouth)
        let n = 1 << 16
        var response = [Double](repeating: 0, count: n)
        for t in 0..<n {
            guide.step(flow: t == 0 ? 1 : 0)
            response[t] = guide.mouth.flow
        }
        let peaks = Acoustics.Voice.Spectrum.peaks(of: response, rate: guide.rate, width: 40)
        return peaks.prefix(count).map { Frequency.hertz($0) }
    }

    /// The number of waveguide sections: at least `minimum`, and a multiple of the number of pieces, so that
    /// every change of area falls on a junction.
    func sections(atLeast minimum: Int) -> Int {
        let pieces = Swift.max(areas.count, 1)
        return pieces * ((minimum + pieces - 1) / pieces)
    }
}
