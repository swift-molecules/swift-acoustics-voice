import Acoustics_Voice
import Testing

extension `Acoustics.Voice Tests` {
    @Suite struct Folds {}
}

extension `Acoustics.Voice Tests`.Folds {
    typealias Base = `Acoustics.Voice Tests`

    /// The human folds on a uniform tract of 17 cm and 3 cm², held at `pressure` and `tension` for half a second;
    /// the fundamental and RMS pressure at 1 m over 0.25–0.42 s.
    static func sustain(
        _ folds: Acoustics.Voice.Folds = .human,
        pressure: Double,
        tension: Double = 1
    ) -> (fundamental: Double, rms: Double) {
        let voice = Acoustics.Voice(
            tract: .uniform(length: Base.metres(0.17), area: Base.area(3e-4)),
            source: .folds(folds),
            call: Acoustics.Voice.Call(points: [
                Base.point(0, pressure, tension: tension, mouth: 3e-4),
                Base.point(0.5, pressure, tension: tension, mouth: 3e-4),
            ])
        )
        let samples = voice.render(rate: Frequency.hertz(48000)).map { $0.underlying }
        let held = Array(samples[12000..<20000])
        let rms = (held.reduce(0) { $0 + $1 * $1 } / Double(held.count)).squareRoot()
        return (Base.fundamental(held, rate: 48000, low: 40, high: 1000), rms)
    }

    @Test
    func `The human folds phonate near the pitch Steinecke and Herzel report`() {
        let sound = Self.sustain(pressure: 800)
        #expect(sound.fundamental > 100 && sound.fundamental < 160, "\(sound.fundamental) Hz")
        #expect(sound.rms > 0.005, "\(sound.rms) Pa")
    }

    @Test
    func `Below the threshold pressure the folds stay still`() {
        let sound = Self.sustain(pressure: 100)
        #expect(sound.rms < 1e-6, "\(sound.rms) Pa")
    }

    @Test
    func `The pitch is proportional to the tension`() {
        let one = Self.sustain(pressure: 800).fundamental
        let two = Self.sustain(pressure: 800, tension: 2).fundamental
        #expect(Base.error(two, 2 * one) < 0.03, "\(one) Hz and \(two) Hz")
    }

    @Test
    func `Folds twice as large in every length phonate about an octave lower`() {
        let one = Self.sustain(pressure: 800, tension: 2).fundamental
        let two = Self.sustain(.human.scaled(by: 2), pressure: 800, tension: 2).fundamental
        #expect(Base.error(one, 2 * two) < 0.1, "\(one) Hz and \(two) Hz")
    }
}
