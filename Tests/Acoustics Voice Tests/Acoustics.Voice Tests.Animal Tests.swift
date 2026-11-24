import Acoustics_Voice
import Testing

extension `Acoustics.Voice Tests` {
    @Suite struct Animal {}
}

extension `Acoustics.Voice Tests`.Animal {
    typealias Base = `Acoustics.Voice Tests`
    static let rate = 48000.0

    static func render(_ voice: Acoustics.Voice) -> [Double] {
        voice.render(rate: Frequency.hertz(rate)).map { $0.underlying }
    }

    static func stretch(_ samples: [Double], _ start: Double, _ end: Double) -> [Double] {
        Array(samples[Int(start * rate)..<Int(end * rate)])
    }

    /// Formant dispersion as Reby and McComb (2003, Anim. Behav. 65, 519) estimate it: the slope, through the
    /// origin, of the formants against (2i − 1) / 2.
    static func dispersion(_ formants: [Frequency.Value<Double>]) -> Double {
        var sum = 0.0
        var squares = 0.0
        for (i, formant) in formants.enumerated() {
            let x = Double(2 * i + 1) / 2
            sum += x * formant.underlying
            squares += x * x
        }
        return sum / squares
    }

    @Test
    func `The dog's formant dispersion is a growl's and a bark's`() {
        // Threatening growls, 795 ± 170.7 Hz (Faragó et al. 2017, R. Soc. Open Sci. 4, 170134, Table S4); a
        // Malinois's bark, 744 Hz (Li et al. 2026, Vet. Sci. 13, 519, Table 1).
        let dispersion = Self.dispersion(Acoustics.Voice.dog.tract.formants(count: 4))
        #expect(Swift.abs(dispersion - 795) < 170.7, "\(dispersion) Hz")
        #expect(Base.error(dispersion, 744) < 0.1, "\(dispersion) Hz")
    }

    @Test
    func `The dog barks within a measured bark's pitch`() {
        // 415.7 ± 95.1 Hz (Li et al. 2026, Table 1).
        let bark = Self.stretch(Self.render(.dog), 0.06, 0.17)
        let f0 = Base.fundamental(bark, rate: Self.rate, low: 60, high: 1500)
        #expect(Swift.abs(f0 - 415.7) < 95.1, "\(f0) Hz")
    }

    @Test
    func `The cat meows at a measured meow's pitch and brightness`() {
        // F0 698 Hz mean, 221–1185 Hz (Schötz 2012 in Tavernier et al. 2020, J. Vet. Sci. 21, e18, Table 2);
        // spectral centroid 530–3680 Hz (Russo et al. 2025, Sci. Rep. 15, 43490, Results).
        let meow = Self.render(.cat)
        let middle = Base.fundamental(Self.stretch(meow, 0.2, 0.32), rate: Self.rate, low: 150, high: 1500)
        #expect(Base.error(middle, 698) < 0.15, "\(middle) Hz")
        for (start, end) in [(0.08, 0.2), (0.2, 0.32), (0.4, 0.52)] {
            let f0 = Base.fundamental(Self.stretch(meow, start, end), rate: Self.rate, low: 150, high: 1500)
            #expect(f0 > 221 && f0 < 1185, "\(f0) Hz at \(start) s")
        }
        let centroid = Base.centroid(Self.stretch(meow, 0.06, 0.56), rate: Self.rate)
        #expect(centroid > 530 && centroid < 3680, "\(centroid) Hz")
    }

    @Test
    func `The donkey's formants are near a horse's`() {
        // A horse's whinny, F1–F4 = 238 ± 53, 541 ± 72, 1005 ± 85, 1332 ± 125 Hz (Briefer et al. 2015, Sci. Rep.
        // 5, 9989, Table S1); within two deviations, the tract's length being taken from their spacing.
        let formants = Acoustics.Voice.donkey.tract.formants(count: 4).map(\.underlying)
        for (formant, (mean, deviation)) in zip(formants, [(238.0, 53.0), (541, 72), (1005, 85), (1332, 125)]) {
            #expect(Swift.abs(formant - mean) < 2 * deviation, "\(formant) Hz, measured \(mean)")
        }
    }

    @Test
    func `The donkey's hee is a horse whinny's pitch and its haw far below`() {
        // A whinny's lower fundamental, 385 ± 87 Hz (Briefer et al. 2015, Table S1).
        let bray = Self.render(.donkey)
        let hee = Base.fundamental(Self.stretch(bray, 0.15, 0.45), rate: Self.rate, low: 60, high: 1500)
        let haw = Base.fundamental(Self.stretch(bray, 0.7, 1.0), rate: Self.rate, low: 60, high: 1500)
        #expect(Swift.abs(hee - 385) < 87, "\(hee) Hz")
        #expect(haw < hee / 2, "\(haw) Hz")
    }

    @Test
    func `The rooster's trachea rings as a tube closed at the syrinx`() {
        // f = (2n − 1) c / 4(L + 8a / 3π) for the 171 mm trachea of radius 2.9 mm.
        let formants = Acoustics.Voice.rooster.tract.formants(count: 3)
        let length = 0.171 + 8 * 2.9e-3 / (3 * Double.pi)
        for (n, formant) in formants.enumerated() {
            let exact = Double(2 * n + 1) * Base.c / (4 * length)
            #expect(Base.error(formant.underlying, exact) < 0.01, "\(formant.underlying) Hz, exact \(exact)")
        }
    }

    @Test
    func `The rooster crows below its trachea's first resonance with a band where crows have theirs`() {
        // Crows' most distinct band, 1737 ± 60 Hz in White Leghorns' last syllable and 1974–2426 Hz in red
        // junglefowl (Wright et al. 2025, Phil. Trans. R. Soc. B 380, 20240199, Table 2): between 1.5 and 2.5 kHz.
        let crow = Self.render(.rooster)
        let resonance = Acoustics.Voice.rooster.tract.formants(count: 1)[0].underlying
        let last = Self.stretch(crow, 0.66, 1.47)
        let f0 = Base.fundamental(last, rate: Self.rate, low: 150, high: 1500)
        #expect(f0 > 300 && f0 < resonance, "\(f0) Hz, resonance \(resonance) Hz")
        let band =
            Base.spectrum(last, rate: Self.rate)
            .filter { $0.frequency > 1000 && $0.frequency < 4000 }
            .max { $0.power < $1.power }?.frequency ?? 0
        #expect(band > 1500 && band < 2500, "\(band) Hz")
    }
}
