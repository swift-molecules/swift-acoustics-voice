extension Acoustics.Voice {
    /// A dog's bark.
    ///
    /// - Tract: 20.6 cm, the vocal tract of a dog of about 40 kg (Taylor, Reby and McComb 2011, PLoS ONE 6,
    ///   e17069, Methods, after Riede and Fitch 1999, J. Exp. Biol. 202, 2859), as one tube of 7 cm²; the area is
    ///   not from a measurement, and a uniform tube's resonances do not depend on it beyond the mouth's end
    ///   correction.
    /// - Folds: the canine larynx is the usual model of the human one, its folds "on the order of 10 mm" long (Tao,
    ///   Regner, Zhang and Jiang 2011, Acta Acust. 97, 669, Discussion), so the human folds scaled to 10 mm.
    /// - Pressure: 2 kPa (20 cmH₂O), between the excised canine larynx's phonation threshold, 7.25 ± 2.91 cmH₂O
    ///   (Tao et al. 2011), and its instability pressure, 33.4 ± 17.5 cmH₂O (Hoffman et al. 2012, J. Voice 26,
    ///   280, Table 1).
    /// - Tension: set so the bark sounds within a Malinois's bark, 415.7 ± 95.1 Hz (Li et al. 2026, Vet. Sci. 13,
    ///   519, Table 1), at about 367 Hz: below the tube's first resonance, 392 Hz, above which these folds break
    ///   up. It is the one value set to the call.
    /// - Mouth: opening from 3 to 14 cm² through the bark, falling to 6 cm²; not from a measurement.
    public static var dog: Self {
        let tension = 2.25
        return Self(
            tract: .uniform(length: Space.Physical.metres(0.206), area: Area<Space.Physical>.amount(7e-4)),
            source: .folds(.human.scaled(by: 10.0 / 14.0)),
            call: .phrases(
                [
                    (
                        start: 0.02, end: 0.2, pressure: 1961, tension: (tension, 0.85 * tension),
                        mouth: (3e-4, 14e-4)
                    )
                ],
                ramp: 0.03
            )
        )
    }

}
