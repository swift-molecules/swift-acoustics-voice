import Acoustics_Voice
import Testing

@Suite struct `Acoustics.Voice Tests` {}

extension `Acoustics.Voice Tests` {
    static let air = Acoustics.Air.room
    static var c: Double { air.speed.underlying }

    static func error(_ value: Double, _ expected: Double) -> Double {
        Swift.abs(value - expected) / expected
    }

    static func metres(_ value: Double) -> Measure<1, Space.Physical>.Value<Double> {
        Space.Physical.metres(value)
    }

    static func area(_ square: Double) -> Area<Space.Physical>.Value<Double> {
        Area<Space.Physical>.amount(square)
    }

    static func point(
        _ time: Double,
        _ pressure: Double,
        tension: Double,
        mouth: Double
    ) -> Acoustics.Voice.Call.Point {
        Acoustics.Voice.Call.Point(
            time: Time.Duration.amount(time),
            pressure: Pressure.pascals(pressure),
            tension: tension,
            mouth: area(mouth)
        )
    }

    /// The fundamental of a stretch of pressure, in hertz: the shortest lag whose autocorrelation peak is within 10% of the highest between
    /// `low` and `high` hertz, refined by a parabola.
    static func fundamental(_ samples: [Double], rate: Double, low: Double, high: Double) -> Double {
        let shortest = Int(rate / high)
        let longest = Int(rate / low)
        let n = samples.count - longest - 1
        guard n > 0 else { return 0 }
        func correlation(_ lag: Int) -> Double {
            var sum = 0.0
            var a = 0.0
            var b = 0.0
            for t in 0..<n {
                sum += samples[t] * samples[t + lag]
                a += samples[t] * samples[t]
                b += samples[t + lag] * samples[t + lag]
            }
            return sum / ((a * b).squareRoot() + 1e-300)
        }
        let values = (shortest - 1...longest + 1).map(correlation)
        let peaks = (1..<(values.count - 1)).filter { i in
            values[i] >= values[i - 1] && values[i] >= values[i + 1]
        }
        let highest = peaks.map { values[$0] }.max() ?? 0
        guard let best = peaks.first(where: { values[$0] >= 0.9 * highest }) else { return 0 }
        let offset = 0.5 * (values[best - 1] - values[best + 1])
            / (values[best - 1] - 2 * values[best] + values[best + 1])
        return rate / (Double(shortest - 1 + best) + offset)
    }
}
