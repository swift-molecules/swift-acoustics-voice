extension Acoustics.Voice.Call {
    /// Builds a call from phrases, each held at one pressure, rising and falling at its ends.
    static func phrases(
        _ phrases: [(start: Double, end: Double, pressure: Double, tension: (Double, Double), mouth: (Double, Double))],
        ramp: Double
    ) -> Self {
        var points: [Point] = [
            Point(
                time: Time.Duration.amount(0),
                pressure: Pressure.pascals(0),
                tension: phrases.first?.tension.0 ?? 1,
                mouth: Area<Space.Physical>.amount(phrases.first?.mouth.0 ?? 1e-4)
            )
        ]
        for phrase in phrases {
            func point(_ time: Double, _ pressure: Double, _ w: Double) -> Point {
                Point(
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
