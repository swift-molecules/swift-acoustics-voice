import Acoustics_Voice
import Fourier
import Numeric
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
    ) -> Acoustics.Voice.Moment {
        Acoustics.Voice.Moment(
            time: Time.Duration.amount(time),
            pressure: Pressure.pascals(pressure),
            tension: tension,
            mouth: area(mouth)
        )
    }

    /// The fundamental of a stretch of pressure, in hertz: the shortest lag between `low` and `high` hertz whose
    /// autocorrelation peak is within 10% of the highest, refined by a parabola.
    static func fundamental(_ samples: [Double], rate: Double, low: Double, high: Double) -> Double {
        let shortest = Int(rate / high)
        let longest = Int(rate / low)
        let n = samples.endIndex - longest - 1
        guard n > 0 else { return 0 }
        func correlation(_ lag: Int) -> Double {
            var sum = 0.0
            var a = 0.0
            var b = 0.0
            for t in samples.indices.prefix(n) {
                sum += samples[t] * samples[t + lag]
                a += samples[t] * samples[t]
                b += samples[t + lag] * samples[t + lag]
            }
            return sum / ((a * b).squareRoot() + 1e-300)
        }
        let values = (shortest - 1...longest + 1).map(correlation)
        let peaks = (1..<(values.endIndex - 1)).filter { i in
            values[i] >= values[i - 1] && values[i] >= values[i + 1]
        }
        let highest = peaks.map { values[$0] }.max() ?? 0
        guard let best = peaks.first(where: { values[$0] >= 0.9 * highest }) else { return 0 }
        let offset =
            0.5 * (values[best - 1] - values[best + 1])
            / (values[best - 1] - 2 * values[best] + values[best + 1])
        return rate / (Double(shortest - 1 + best) + offset)
    }

    /// The power spectrum of a stretch under a Hann window, zero-padded to 2¹⁶, with each bin's frequency.
    static func spectrum(_ samples: [Double], rate: Double) -> [(frequency: Double, power: Double)] {
        let n = 1 << 16
        let count = samples.count
        var padded = [Double](repeating: 0, count: n)
        for t in samples.indices.prefix(n) {
            padded[t] = samples[t] * (0.5 - 0.5 * Double.cos(2 * Double.pi * Double(t) / Double(count)))
        }
        let bins: [Complex.Number<Double>]
        do throws(Fourier.Error) {
            bins = try Fourier.Transform<Double>(count: Cardinal(UInt(n))).forward(real: padded)
        } catch {
            return []
        }
        return bins.enumerated().map { k, bin in
            let m = bin.magnitude().value
            return (Double(k) * rate / Double(n), m * m)
        }
    }

    /// The spectral centroid, in hertz: the power-weighted mean frequency.
    static func centroid(_ samples: [Double], rate: Double) -> Double {
        let bins = spectrum(samples, rate: rate)
        let total = bins.reduce(0) { $0 + $1.power }
        return bins.reduce(0) { $0 + $1.frequency * $1.power } / total
    }

    /// The frequency of the spectrum's strongest bin, in hertz.
    static func dominant(_ samples: [Double], rate: Double) -> Double {
        spectrum(samples, rate: rate).max { $0.power < $1.power }?.frequency ?? 0
    }
}
