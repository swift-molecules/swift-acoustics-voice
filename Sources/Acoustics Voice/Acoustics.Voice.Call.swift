public import Acoustics

extension Acoustics.Voice {
    /// What the animal does over one call: the pressure it drives the air with, the tension it holds the source
    /// at, and how wide it opens its mouth, each straight between points.
    public struct Call: Hashable, Sendable {
        /// In time order, the first at zero. Before the first and after the last, the nearest holds.
        public var points: [Point]

        public init(points: [Point]) {
            self.points = points
        }
    }
}

extension Acoustics.Voice.Call {
    /// One moment of a call.
    public struct Point: Hashable, Sendable {
        public var time: Time.Duration.Value<Double>
        /// Below the source: from the lungs, or from the air sacs of a bird.
        public var pressure: Pressure.Value<Double>
        /// The source's tension Q, one for its values as given.
        public var tension: Double
        /// The area of the tract's last piece, at the mouth.
        public var mouth: Area<Space.Physical>.Value<Double>

        public init(
            time: Time.Duration.Value<Double>,
            pressure: Pressure.Value<Double>,
            tension: Double,
            mouth: Area<Space.Physical>.Value<Double>
        ) {
            self.time = time
            self.pressure = pressure
            self.tension = tension
            self.mouth = mouth
        }
    }
}

extension Acoustics.Voice.Call {
    /// How long the call lasts: the time of its last point.
    public var duration: Time.Duration.Value<Double> {
        points.last?.time ?? .zero
    }

    /// The pressure, tension and mouth area, in SI units, at `time` seconds.
    func state(at time: Double) -> (pressure: Double, tension: Double, mouth: Double) {
        guard let first = points.first else { return (0, 1, 0) }
        guard time > first.time.underlying else {
            return (first.pressure.underlying, first.tension, first.mouth.underlying)
        }
        for (a, b) in zip(points, points.dropFirst()) where time <= b.time.underlying {
            let span = b.time.underlying - a.time.underlying
            let w = span > 0 ? (time - a.time.underlying) / span : 1
            return (
                a.pressure.underlying + w * (b.pressure.underlying - a.pressure.underlying),
                a.tension + w * (b.tension - a.tension),
                a.mouth.underlying + w * (b.mouth.underlying - a.mouth.underlying)
            )
        }
        guard let last = points.last else { return (0, 1, 0) }
        return (last.pressure.underlying, last.tension, last.mouth.underlying)
    }
}
