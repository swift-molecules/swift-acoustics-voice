public import Acoustics

extension Acoustics.Voice {
    /// One moment of a call: the pressure, tension and mouth opening, held or passed through then.
    public struct Moment: Hashable, Sendable {
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
