extension Acoustics.Voice {
    /// A donkey's bray: a high "hee" and a low "haw", twice.
    ///
    /// No measurement of the donkey's vocal tract, folds or bray could be read, so the horse stands in for it.
    ///
    /// - Tract: 47 cm, the closed–open tube whose formant spacing is that of a horse's whinny, F1–F4 = 238, 541,
    ///   1005 and 1332 Hz (Briefer et al. 2015, Sci. Rep. 5, 9989, Table S1), as one tube of 20 cm², the area not
    ///   from a measurement.
    /// - Folds: a horse's folds are 24 ± 5 mm long (Lefèvre et al. 2026, Curr. Biol.; from secondary reports), so
    ///   the human folds scaled to 24 mm.
    /// - Pressure: 2 kPa, as for the dog; assumed.
    /// - Tension: the "hee" near 400 Hz, about a horse whinny's lower fundamental, 385 ± 87 Hz (Briefer et al.
    ///   2015, Table S1), and the "haw" near 130 Hz; the haw's pitch is assumed. The hee is drawn in by a real
    ///   donkey (Browning and Scheifele 2001, J. Acoust. Soc. Am. 110, 2654, abstract); here both are blown out.
    public static var donkey: Self {
        let high = 5.0
        let low = 1.82
        let hee = (tension: (high, 1.1 * high), mouth: (6e-4, 12e-4))
        let haw = (tension: (low, 0.8 * low), mouth: (16e-4, 10e-4))
        return Self(
            tract: .uniform(length: Space.Physical.metres(0.47), area: Area<Space.Physical>.amount(20e-4)),
            source: .folds(.human.scaled(by: 24.0 / 14.0)),
            call: .phrases(
                [
                    (start: 0.05, end: 0.5, pressure: 2000, tension: hee.tension, mouth: hee.mouth),
                    (start: 0.55, end: 1.2, pressure: 2000, tension: haw.tension, mouth: haw.mouth),
                    (start: 1.3, end: 1.75, pressure: 2000, tension: hee.tension, mouth: hee.mouth),
                    (start: 1.8, end: 2.45, pressure: 2000, tension: haw.tension, mouth: haw.mouth),
                ],
                ramp: 0.05
            )
        )
    }

}
