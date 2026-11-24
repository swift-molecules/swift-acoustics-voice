import Fourier
import Numeric

extension Acoustics.Voice {
    /// Where a response's spectrum peaks.
    enum Spectrum {}
}

extension Acoustics.Voice.Spectrum {
    /// The frequencies, in hertz and ascending, at which the magnitude of the response's transform is greatest
    /// within `width` hertz either side, each refined by a parabola through the logarithms of its bin and the two
    /// beside it. The response is zero-padded to the next power of two of at least four times its length.
    static func peaks(of response: [Double], rate: Double, width: Double) -> [Double] {
        var n = 1
        while n < 4 * response.count { n <<= 1 }
        guard let transform = try? Fourier.Transform<Double>(count: Cardinal(UInt(n))),
            let spectrum = try? transform.forward(real: response + [Double](repeating: 0, count: n - response.count))
        else { return [] }
        let magnitude = spectrum.map { Double.log($0.magnitude().value + 1e-300) }
        let bin = rate / Double(n)
        let reach = Swift.max(1, Int(width / bin))
        var result: [Double] = []
        var k = 1
        while k < magnitude.endIndex - 1 {
            let lower = Swift.max(0, k - reach)
            let upper = Swift.min(magnitude.endIndex - 1, k + reach)
            var highest = true
            for j in lower...upper where j != k && magnitude[j] >= magnitude[k] {
                highest = false
                break
            }
            if highest {
                let a = magnitude[k - 1]
                let b = magnitude[k]
                let c = magnitude[k + 1]
                let offset = 0.5 * (a - c) / (a - 2 * b + c)
                result.append((Double(k) + offset) * bin)
                k += reach
            } else {
                k += 1
            }
        }
        return result
    }
}
