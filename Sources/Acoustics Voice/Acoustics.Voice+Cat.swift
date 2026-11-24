extension Acoustics.Voice {
    /// A cat's meow: the mouth opening and closing, "mi-a-ow", the pitch rising and falling.
    ///
    /// - Tract: 8 cm from glottis to lips (Weissengruber et al. 2002, J. Anat. 201, 195, Table 2; read from a
    ///   search excerpt of the table, not the paper), as one tube of 1.5 cm², the area not from a measurement.
    /// - Folds: membranous folds 7.5 mm long (Herbst et al. 2023, Curr. Biol. 33, 4727; from a secondary report),
    ///   so the human folds scaled to 7.5 mm.
    /// - Pressure: 1 kPa, assumed: no measurement for the cat was reachable.
    /// - Tension: set so the meow's middle sounds near 700 Hz, the mean of 698 Hz over three cats (Schötz 2012, as
    ///   tabulated by Tavernier et al. 2020, J. Vet. Sci. 21, e18, Table 2; range 221–1185 Hz).
    /// - Mouth: 0.3 cm² at the start, 2.5 cm² open, back to 0.4 cm²; not from a measurement.
    public static var cat: Self {
        let tension = 2.7
        func moment(_ time: Double, _ pressure: Double, _ q: Double, _ mouth: Double) -> Moment {
            Moment(
                time: Time.Duration.amount(time),
                pressure: Pressure.pascals(pressure),
                tension: q * tension,
                mouth: Area<Space.Physical>.amount(mouth)
            )
        }
        return Self(
            tract: .uniform(length: Space.Physical.metres(0.08), area: Area<Space.Physical>.amount(1.5e-4)),
            source: .folds(.human.scaled(by: 7.5 / 14.0)),
            call: Call(points: [
                moment(0, 0, 0.85, 0.3e-4),
                moment(0.06, 1000, 0.9, 0.5e-4),
                moment(0.25, 1000, 1.08, 2.5e-4),
                moment(0.45, 1000, 0.95, 1.2e-4),
                moment(0.56, 600, 0.8, 0.4e-4),
                moment(0.62, 0, 0.75, 0.4e-4),
            ])
        )
    }
}
