import Acoustics_Voice
import Numeric
import Testing

extension `Acoustics.Voice Tests` {
    @Suite struct Tract {}
}

extension `Acoustics.Voice Tests`.Tract {
    typealias Base = `Acoustics.Voice Tests`

    @Test
    func `A uniform tube closed at the source rings at odd quarter wavelengths`() {
        // f = (2n − 1) c / 4L.
        let length = 0.17
        let tract = Acoustics.Voice.Tract.uniform(length: Base.metres(length), area: Base.area(3e-4))
        let formants = tract.formants(count: 5, air: Base.air, mouth: .open)
        #expect(formants.count == 5)
        for (n, formant) in formants.enumerated() {
            let exact = Double(2 * n + 1) * Base.c / (4 * length)
            #expect(Base.error(formant.underlying, exact) < 0.003, "\(formant.underlying) Hz, exact \(exact)")
        }
    }

    @Test
    func `Two tubes ring where their impedances match`() throws {
        // Closed at the source, open at the mouth: A₁ tan(kL₁) = A₂ cot(kL₂), solved by bisection.
        let (l1, l2, a1, a2) = (0.09, 0.08, 1e-4, 7e-4)
        let tract = Acoustics.Voice.Tract(
            length: Base.metres(l1 + l2),
            areas: [
                Base.area(a1), Base.area(a1), Base.area(a1), Base.area(a1), Base.area(a1), Base.area(a1),
                Base.area(a1), Base.area(a1), Base.area(a1),
                Base.area(a2), Base.area(a2), Base.area(a2), Base.area(a2), Base.area(a2), Base.area(a2),
                Base.area(a2), Base.area(a2),
            ])
        func g(_ f: Double) -> Double {
            let k = 2 * Double.pi * f / Base.c
            return a1 * Double.sin(k * l1) * Double.sin(k * l2) - a2 * Double.cos(k * l1) * Double.cos(k * l2)
        }
        var exact: [Double] = []
        var f = 10.0
        while exact.count < 4 {
            if g(f) * g(f + 5) <= 0 {
                var (low, high) = (f, f + 5)
                for _ in 0..<60 {
                    let mid = (low + high) / 2
                    if g(low) * g(mid) <= 0 { high = mid } else { low = mid }
                }
                exact.append((low + high) / 2)
            }
            f += 5
        }
        let formants = tract.formants(count: 4, air: Base.air, mouth: .open)
        #expect(formants.count == 4)
        for (formant, e) in zip(formants, exact) {
            #expect(Base.error(formant.underlying, e) < 0.003, "\(formant.underlying) Hz, exact \(e)")
        }
    }

    @Test
    func `A radiating mouth lengthens the tube by the baffled piston's end correction`() {
        // The parallel inertance is that of a tube 8a / 3π longer, so F₁ ≈ c / 4(L + 8a / 3π).
        let length = 0.17
        let radius = 0.01
        let tract = Acoustics.Voice.Tract.uniform(
            length: Base.metres(length),
            area: Base.area(Double.pi * radius * radius)
        )
        let first = tract.formants(count: 1, air: Base.air, mouth: .radiating)[0].underlying
        let exact = Base.c / (4 * (length + 8 * radius / (3 * Double.pi)))
        #expect(Base.error(first, exact) < 0.003, "\(first) Hz, exact \(exact)")
        #expect(first < Base.c / (4 * length))
    }

    @Test
    func `Formants scale inversely with the tract's length`() {
        let short = Acoustics.Voice.Tract(length: Base.metres(0.1), areas: [Base.area(1e-4), Base.area(4e-4)])
        let long = Acoustics.Voice.Tract(length: Base.metres(0.2), areas: [Base.area(4e-4), Base.area(16e-4)])
        let a = short.formants(count: 3, air: Base.air, mouth: .open)
        let b = long.formants(count: 3, air: Base.air, mouth: .open)
        for (x, y) in zip(a, b) {
            #expect(Base.error(x.underlying, 2 * y.underlying) < 0.003)
        }
    }
}
