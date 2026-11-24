public import Acoustics

extension Acoustics.Voice {
    /// What the animal does over one call: the pressure it drives the air with, the tension it holds the source
    /// at, and how wide it opens its mouth, each straight between points.
    public struct Call: Hashable, Sendable {
        /// In time order, the first at zero. Before the first and after the last, the nearest holds.
        public var points: [Acoustics.Voice.Moment]

        public init(points: [Acoustics.Voice.Moment]) {
            self.points = points
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

extension Acoustics.Voice.Call {
    /// Builds a call from phrases, each held at one pressure, rising and falling at its ends.
    static func phrases(
        _ phrases: [(start: Double, end: Double, pressure: Double, tension: (Double, Double), mouth: (Double, Double))],
        ramp: Double
    ) -> Self {
        var points: [Acoustics.Voice.Moment] = [
            Acoustics.Voice.Moment(
                time: Time.Duration.amount(0),
                pressure: Pressure.pascals(0),
                tension: phrases.first?.tension.0 ?? 1,
                mouth: Area<Space.Physical>.amount(phrases.first?.mouth.0 ?? 1e-4)
            )
        ]
        for phrase in phrases {
            func point(_ time: Double, _ pressure: Double, _ w: Double) -> Acoustics.Voice.Moment {
                Acoustics.Voice.Moment(
                    time: Time.Duration.amount(time),
                    pressure: Pressure.pascals(pressure),
                    tension: phrase.tension.0 + w * (phrase.tension.1 - phrase.tension.0),
                    mouth: Area<Space.Physical>.amount(phrase.mouth.0 + w * (phrase.mouth.1 - phrase.mouth.0))
                )
            }
            let span = phrase.end - phrase.start
            points.append(point(phrase.start, 0, 0))
            points.append(point(phrase.start + ramp, phrase.pressure, ramp / span))
            points.append(point(phrase.end - ramp, phrase.pressure, 1 - ramp / span))
            points.append(point(phrase.end, 0, 1))
        }
        return Self(points: points)
    }
}
