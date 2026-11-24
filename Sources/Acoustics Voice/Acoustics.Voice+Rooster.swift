extension Acoustics.Voice {
    /// A rooster's crow: four syllables, the last long, "cock-a-doodle-doo".
    ///
    /// - Tract: the trachea, 171 mm long and 5.8 mm across, the values of a fowl of about 2 kg (Sverdlova et al.
    ///   2012, PLoS ONE 7, e45315, Methods, after McLelland 1989). The beak and oropharynx above it are left out.
    /// - Syrinx: the labia span the 5.8 mm airway; their mass, stiffness, thickness, openings and wave delay are
    ///   assumed, since no measurement of the fowl's labia could be read. The labium's own frequency is about
    ///   500 Hz at tension one.
    /// - Pressure: 6 kPa, the air-sac pressure of a crowing cockerel, 60 cmH₂O (Brackenbury 1978, J. Exp. Biol.
    ///   72, 229; from the abstract).
    /// - Tension: rising through the syllables and falling at the end of the last; the pitch is assumed, since no
    ///   crow's fundamental could be read. The labia only sound below the trachea's first resonance, near 494 Hz,
    ///   and are pulled toward it as the tension rises (as Riede, Thomson, Titze and Goller 2019, PLoS Biol. 17,
    ///   e2006507, Fig. 4, found a shorter trachea raises the pitch).
    public static var rooster: Self {
        let q = 1.0
        return Self(
            tract: .uniform(
                length: Space.Physical.metres(0.171),
                area: Area<Space.Physical>.amount(Double.pi * 2.9e-3 * 2.9e-3)
            ),
            source: .syrinx(.fowl),
            call: .phrases(
                [
                    (start: 0.02, end: 0.17, pressure: 6000, tension: (0.85 * q, 0.95 * q), mouth: (26e-6, 26e-6)),
                    (start: 0.22, end: 0.32, pressure: 6000, tension: (0.95 * q, 1.0 * q), mouth: (26e-6, 26e-6)),
                    (start: 0.36, end: 0.58, pressure: 6000, tension: (1.0 * q, 1.1 * q), mouth: (26e-6, 26e-6)),
                    (start: 0.63, end: 1.5, pressure: 6000, tension: (1.2 * q, 0.85 * q), mouth: (26e-6, 26e-6)),
                ],
                ramp: 0.02
            )
        )
    }

}

extension Acoustics.Voice.Syrinx {
    /// The fowl's labia as assumed for `Acoustics.Voice.rooster`: 5.8 mm long across the airway (its width,
    /// Sverdlova et al. 2012), 1.5 mm thick and 1 mm deep, of soft tissue at 1040 kg/m³, so 9 mg; a stiffness for
    /// an own frequency of 500 Hz; a damping ratio of 0.1; a cubic damping keeping the swing near a millimetre;
    /// openings of 0.6 and 0.3 mm²; a surface wave crossing half the labium in 0.1 ms.
    public static var fowl: Self {
        let mass = 1040 * 5.8e-3 * 1.5e-3 * 1e-3
        let omega = 2 * Double.pi * 500
        return Self(
            mass: Mass.kilograms(mass),
            stiffness: Stiffness.amount(mass * omega * omega),
            loss: Loss.amount(0.2),
            saturation: 2e3,
            length: Space.Physical.metres(5.8e-3),
            thickness: Space.Physical.metres(1.5e-3),
            entry: Area<Space.Physical>.amount(0.6e-6),
            exit: Area<Space.Physical>.amount(0.3e-6),
            delay: Time.Duration.amount(0.1e-3)
        )
    }
}
